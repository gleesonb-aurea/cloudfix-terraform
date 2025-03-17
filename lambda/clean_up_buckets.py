#!/usr/bin/env python3
import boto3
import cfnresponse

def return_response_to_cf(event, context, status, reason):
  if event and event.get('ResponseURL'):
    cfnresponse.send(event, context, status, {}, reason=reason)

def lambda_handler(event, context):
  print("Event received:", event)
  try:
      bucket = event['ResourceProperties']['BucketName']

      if event['RequestType'] == 'Delete':
          s3 = boto3.resource('s3')
          bucket = s3.Bucket(bucket)
          for obj in bucket.objects.filter():
              s3.Object(bucket.name, obj.key).delete()

      return_response_to_cf(event, context, cfnresponse.SUCCESS, "All checks passed")
  except Exception as e:
      print(e)
      return_response_to_cf(event, context, cfnresponse.FAILED, str(e))