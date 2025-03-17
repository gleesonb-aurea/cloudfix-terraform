#!/usr/bin/env python3
import boto3
import json
import os

def handler(event, context):
    print("Event received:", event)
    
    # Get the crawler name from environment variable
    crawler_name = os.environ.get('CUR_CRAWLER_NAME')
    if not crawler_name:
        error_msg = "CUR_CRAWLER_NAME environment variable is not set"
        print(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps(error_msg)
        }
    
    # Start the Glue crawler
    try:
        glue = boto3.client('glue')
        glue.start_crawler(Name=crawler_name)
        success_msg = f"Successfully started crawler {crawler_name}"
        print(success_msg)
        return {
            'statusCode': 200,
            'body': json.dumps(success_msg)
        }
    except Exception as e:
        error_msg = f"Failed to start crawler: {str(e)}"
        print(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps(error_msg)
        }