#!/bin/bash
# Multi-account deployment script for CloudFix Terraform

# Variables - update these before running
MANAGEMENT_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
TERRAFORM_DIR="."
IAM_ROLE_NAME="OrganizationAccountAccessRole"  # Default AWS Organizations role

# Check if running from management account
CURRENT_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
if [ "$CURRENT_ACCOUNT_ID" != "$MANAGEMENT_ACCOUNT_ID" ]; then
    echo "Error: This script must be run from the management account ($MANAGEMENT_ACCOUNT_ID)"
    exit 1
fi

# Get all active accounts in organization
echo "Fetching active accounts from AWS Organizations..."
ACCOUNT_IDS=$(aws organizations list-accounts --query 'Accounts[?Status==`ACTIVE`].Id' --output text)

# Count accounts for reporting
TOTAL_ACCOUNTS=$(echo "$ACCOUNT_IDS" | wc -w)
echo "Found $TOTAL_ACCOUNTS active accounts"

# Setup counters
SUCCESSFUL=0
FAILED=0

# Process each account
for ACCOUNT_ID in $ACCOUNT_IDS; do
    # Skip management account since it's handled separately
    if [ "$ACCOUNT_ID" == "$MANAGEMENT_ACCOUNT_ID" ]; then
        echo "Skipping management account $ACCOUNT_ID (already processed)"
        continue
    fi
    
    echo "Processing account $ACCOUNT_ID..."
    
    # Create workspace for this account if it doesn't exist
    terraform workspace new $ACCOUNT_ID 2>/dev/null || terraform workspace select $ACCOUNT_ID
    
    # Assume role in child account
    echo "Assuming role in account $ACCOUNT_ID..."
    STS_CREDENTIALS=$(aws sts assume-role \
        --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/${IAM_ROLE_NAME}" \
        --role-session-name "CloudFixDeployment" \
        --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
        --output text)
    
    if [ $? -ne 0 ]; then
        echo "Failed to assume role in account $ACCOUNT_ID"
        FAILED=$((FAILED+1))
        continue
    fi
    
    # Set temporary credentials as environment variables
    export AWS_ACCESS_KEY_ID=$(echo $STS_CREDENTIALS | cut -f1 -d' ')
    export AWS_SECRET_ACCESS_KEY=$(echo $STS_CREDENTIALS | cut -f2 -d' ')
    export AWS_SESSION_TOKEN=$(echo $STS_CREDENTIALS | cut -f3 -d' ')
    
    # Apply Terraform for this account (only creating the finder role)
    echo "Applying Terraform for account $ACCOUNT_ID..."
    terraform apply -var="account_id=$ACCOUNT_ID" -var="deploy_finder_role_only=true" -auto-approve
    
    if [ $? -eq 0 ]; then
        echo "Successfully deployed CloudFix Finder Role to account $ACCOUNT_ID"
        SUCCESSFUL=$((SUCCESSFUL+1))
    else
        echo "Failed to deploy to account $ACCOUNT_ID"
        FAILED=$((FAILED+1))
    fi
    
    # Clear temporary credentials
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
done

# Return to default workspace
terraform workspace select default

# Report results
echo "Deployment complete!"
echo "Successfully deployed to $SUCCESSFUL accounts"
if [ $FAILED -gt 0 ]; then
    echo "Failed to deploy to $FAILED accounts"
    exit 1
fi

echo "CloudFix Finder Role has been deployed across your organization"