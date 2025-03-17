#!/usr/bin/env python3
import boto3
import json

def handler(event, context):
    print("Event received:", event)
    
    # Extract parameters
    try:
        bucket_name = event['BucketName']
        target_lambda_arn = event.get('TargetLambdaArn')
        report_key = event.get('ReportKey')
        operation = event.get('Operation', 'Create')
    except KeyError as e:
        error_msg = f"Missing required parameter: {str(e)}"
        print(error_msg)
        return {
            'statusCode': 400,
            'body': json.dumps(error_msg)
        }
    
    # Initialize S3 client
    s3 = boto3.client('s3')
    
    # Create notification configuration
    notification_config = {}
    if operation != 'Delete' and target_lambda_arn and report_key:
        notification_config['LambdaFunctionConfigurations'] = [{
            'Events': ['s3:ObjectCreated:*'],
            'LambdaFunctionArn': target_lambda_arn,
            'Filter': {
                'Key': {
                    'FilterRules': [
                        {
                            'Name': 'prefix',
                            'Value': report_key
                        }
                    ]
                }
            }
        }]
    
    # Apply notification configuration
    try:
        s3.put_bucket_notification_configuration(
            Bucket=bucket_name,
            NotificationConfiguration=notification_config
        )
        success_msg = f"Successfully updated notification configuration for bucket {bucket_name}"
        print(success_msg)
        
        # Create support case for backfilling CUR data if creating notification
        if operation == 'Create':
            try:
                support = boto3.client('support')
                params = {
                    'communicationBody': 'We need recently created CUR report named CloudFix-CUR to contain the data from the last 3 calendar months. Could you backfill the data for CloudFix-CUR?',
                    'subject': 'Backfill CUR data',
                    'categoryCode': 'invoices-and-reports',
                    'ccEmailAddresses': [],
                    'serviceCode': 'billing',
                    'severityCode': 'high'
                }
                case_response = support.create_case(**params)
                print(f"Created support case: {case_response}")
            except Exception as e:
                print(f"Warning: Failed to create support case: {str(e)}")
                # Continue execution even if support case creation fails
        
        return {
            'statusCode': 200,
            'body': json.dumps(success_msg)
        }
    except Exception as e:
        error_msg = f"Failed to update notification configuration: {str(e)}"
        print(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps(error_msg)
        }