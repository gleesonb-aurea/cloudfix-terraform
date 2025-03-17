# CloudFix Terraform Implementation

A simplified Terraform implementation for deploying CloudFix resources across AWS accounts. This repository contains a single Terraform file that handles all resource creation needed for CloudFix integration.

## Overview

This Terraform implementation replaces the CloudFormation templates provided by CloudFix, allowing you to use Terraform to deploy:

- IAM roles required by CloudFix
- Cost and Usage Report (CUR) configuration
- Athena and Glue resources
- Supporting Lambda functions

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

## Multi-Account Deployment

To deploy CloudFix roles to all accounts in your AWS Organization:

1. Make sure you have Organization Admin permissions
2. Run the deployment script:
   ```bash
   ./scripts/deploy_to_accounts.sh

This script will create the CloudFix Finder Role in all active accounts in your organization.

## Lambda Functions

The following Lambda functions are included in the /lambda directory:

- `s3_notification`: Handles S3 bucket notifications
- `cur_initializer`: Initializes Cost and Usage Report (CUR)
- `clean_up_buckets`: Cleans up temporary S3 buckets

Before applying the Terraform configuration, you need to package these Lambda functions:

```bash
zip -j lambda_bucket_cleanup.zip lambda/clean_up_buckets.py
zip -j lambda_function_payload.zip lambda/cur_initializer.py
zip -j lambda_s3_notification.zip lambda/s3_notification.py
```

## Notes

- Ensure you have the necessary permissions to create IAM roles and Cost and Usage Report (CUR) in your AWS account
- The script `deploy_to_accounts.sh` requires Organization Admin permissions
- The Lambda functions are configured to run with the necessary permissions
- After deployment, contact CloudFix support to provide your account ID and role ARNs.
- The CloudFix Finder Role must be deployed to all accounts for proper functioning.
- CUR report data may take up to 24 hours to start appearing in a new CUR.

## Troubleshooting

- Verify that the IAM roles have the correct permissions and trust relationships
- Check that the External ID matches what CloudFix has provided
- Confirm that the CUR report is being generated in the S3 bucket