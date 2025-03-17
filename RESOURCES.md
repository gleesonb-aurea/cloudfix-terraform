# CloudFix Terraform Resources

This document provides a comprehensive list of AWS resources created by the CloudFix Terraform configuration, mapped to their original CloudFormation templates.

## S3 Resources

1. `aws_s3_bucket.cloudfix_cur_bucket` (CUR data storage)
   - Matches `CostUsageBucket` in cloudfix-cur.yaml
   - Includes lifecycle rules for INTELLIGENT_TIERING
   - Server-side encryption with AES256
   - Public access blocking

2. `aws_s3_bucket_policy.cloudfix_cur_policy` (CUR bucket policy)
   - Matches `AWSWritesPolicy` in cloudfix-cur.yaml
   - Allows billingreports.amazonaws.com to write CUR data
   - Enforces SSL/TLS

## IAM Roles

1. `aws_iam_role.cloudfix_finder_role`
   - Matches `cloudfixfinderrole` in cloudfix-resource-account-roles.yaml
   - Read-only permissions for cost opportunity analysis

2. `aws_iam_role.cloudfix_ssm_assumed_role`
   - Matches `cloudfixssmassumedrole` in cloudfix-resource-account-roles.yaml
   - Used by SSM for change requests

3. `aws_iam_role.cloudfix_fixer_approver_role`
   - Matches `cloudfixfixerapproverrole` in cloudfix-resource-account-roles.yaml
   - For approving AWS Change Templates/Requests

4. `aws_iam_role.cloudfix_ssm_update_role`
   - Matches `cloudfixssmupdaterole` in cloudfix-resource-account-roles.yaml
   - For SSM updates

5. `aws_iam_role.cloudfix_backup_job_role`
   - Matches `cloudfixbackupjobrole` in cloudfix-resource-account-roles.yaml
   - For backup operations

6. `aws_iam_role.cloudfix_glue_role`
   - Matches `AWSCURCrawlerComponentFunction` in cloudfix-cur.yaml
   - For Glue crawler operations

7. `aws_iam_role.cloudfix_lambda_s3_notification_role`
   - For Lambda S3 notifications
   - New implementation using SNS instead of CloudFormation custom resources

8. `aws_iam_role.cloudfix_lambda_notification_role`
   - New role for SNS notifications
   - Replaces CloudFormation notification mechanism

## Lambda Functions

1. `aws_lambda_function.cloudfix_cur_initializer`
   - Matches functionality from cloudfix-cur.yaml
   - Starts Glue crawler

2. `aws_lambda_function.cloudfix_s3_notification`
   - Matches `AWSS3CURNotification` in cloudfix-cur.yaml
   - Handles S3 notifications

3. `aws_lambda_function.cloudfix_bucket_cleanup`
   - Matches functionality from cloudfix-cur.yaml
   - Cleans up S3 buckets

4. `aws_lambda_function.cloudfix_notification`
   - New function for SNS notifications
   - Replaces CloudFormation notifications

## Glue Resources

1. `aws_glue_catalog_database.cloudfix_database`
   - For storing CUR data schema

2. `aws_glue_crawler.cloudfix_cur_crawler`
   - Matches `AWSCURCrawler` in cloudfix-cur.yaml
   - Crawls CUR data for Athena queries

## Athena Resources

1. `aws_athena_workgroup.cloudfix_workspace`
   - Matches `CloudFixAthenaWorkGroup` in cloudfix-cur.yaml
   - For CUR data analysis

## CUR Resources

1. `aws_cur_report_definition.cloudfix_cur`
   - Matches `CloudFixCostReport` in cloudfix-cur.yaml
   - Defines CUR report configuration

## SNS Resources (New)

1. `aws_sns_topic.cloudfix_notification`
   - New resource for notifications
   - Replaces CloudFormation custom resources

2. `aws_sns_topic_policy.cloudfix_notification`
   - Permissions for SNS topic

## Key Differences from CloudFormation

1. Removed all CloudFormation-specific resources and dependencies
2. Implemented proper SNS notification system
3. Modernized Lambda functions with standard API responses
4. Improved error handling and logging
5. Better resource naming and tagging consistency
