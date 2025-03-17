#!/usr/bin/env python3
import boto3
import json

def lambda_handler(event, context):
    print("Event received:", event)
    try:
        bucket = event['BucketName']
        
        # If operation is delete, empty the bucket
        if event.get('Operation') == 'Delete':
            s3 = boto3.resource('s3')
            bucket_obj = s3.Bucket(bucket)
            for obj in bucket_obj.objects.filter():
                s3.Object(bucket_obj.name, obj.key).delete()
            print(f"Successfully emptied bucket {bucket}")
            return {
                'statusCode': 200,
                'body': json.dumps(f'Successfully emptied bucket {bucket}')
            }
        
        return {
            'statusCode': 200,
            'body': json.dumps('No action required')
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }