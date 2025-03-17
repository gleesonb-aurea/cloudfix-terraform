#!/usr/bin/env python3
import boto3
import json
import os

def handler(event, context):
    print("Event received:", event)
    
    # Get environment variables
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    tenant_id = os.environ.get('TENANT_ID')
    external_id = os.environ.get('EXTERNAL_ID')
    
    if not all([sns_topic_arn, tenant_id, external_id]):
        error_msg = "Missing required environment variables"
        print(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps(error_msg)
        }
    
    try:
        # Add metadata to the notification
        notification_data = {
            'tenant_id': tenant_id,
            'external_id': external_id,
            'roles': event.get('roles', {})
        }
        
        # Send notification via SNS
        sns = boto3.client('sns')
        response = sns.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(notification_data),
            MessageAttributes={
                'Type': {
                    'DataType': 'String',
                    'StringValue': 'CloudFixResourceNotification'
                }
            }
        )
        
        success_msg = f"Successfully published notification: {response['MessageId']}"
        print(success_msg)
        return {
            'statusCode': 200,
            'body': json.dumps(success_msg)
        }
    except Exception as e:
        error_msg = f"Failed to publish notification: {str(e)}"
        print(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps(error_msg)
        }
