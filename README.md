# CloudFix Terraform Implementation

A simplified Terraform implementation for deploying CloudFix resources across AWS accounts. This repository contains a single Terraform file that handles all resource creation needed for CloudFix integration.

## Overview

This Terraform implementation replaces the CloudFormation templates provided by CloudFix, allowing you to use Terraform to deploy:

- IAM roles required by CloudFix
- Cost and Usage Report (CUR) configuration
- Athena and Glue resources
- Supporting Lambda functions
- SNS notification system

## Prerequisites

- Terraform 1.0 or later
- AWS CLI configured with administrator permissions
- CloudFix account with Tenant ID and External ID
- For multi-account deployment: Organization Management account access

## Quick Start

1. Clone this repository
2. Edit the following variables at the top of `cloudfix.tf`:
   - `tenant_id`: Your CloudFix tenant ID
   - `external_id`: Your CloudFix external ID
   - Other optional variables as needed
3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Multi-Account Deployment

To deploy CloudFix roles to all accounts in your AWS Organization:

1. Make sure you have Organization Admin permissions
2. Run the deployment script:
   ```bash
   ./scripts/deploy_to_accounts.sh
   ```

This script will create the CloudFix Finder Role in all active accounts in your organization.

## Lambda Functions

The following Lambda functions are included in the `/lambda` directory:

- `notification.py`: Handles SNS notifications to CloudFix
- `s3_notification.py`: Handles S3 bucket notifications
- `cur_initializer.py`: Initializes Cost and Usage Report (CUR)
- `clean_up_buckets.py`: Cleans up temporary S3 buckets

To package these Lambda functions, use the provided script:

```bash
./scripts/package_lambdas.sh
```

## Resource Documentation

For a comprehensive list of all AWS resources created by this Terraform configuration and their mappings to the original CloudFormation templates, see [RESOURCES.md](RESOURCES.md).

## Notes

- Ensure you have the necessary permissions to create IAM roles and Cost and Usage Report (CUR) in your AWS account
- The script `deploy_to_accounts.sh` requires Organization Admin permissions
- The Lambda functions are configured to run with the necessary permissions
- After deployment, contact CloudFix support to provide your account ID and role ARNs
- The CloudFix Finder Role must be deployed to all accounts for proper functioning
- CUR report data may take up to 24 hours to start appearing in a new CUR
- SNS notifications are used to communicate with CloudFix about created resources

## Troubleshooting

- Verify that the IAM roles have the correct permissions and trust relationships
- Check that the External ID matches what CloudFix has provided
- Confirm that the CUR report is being generated in the S3 bucket
- Verify that SNS notifications are being delivered successfully
- Check CloudWatch Logs for Lambda function execution logs