#!/usr/bin/env python3
import boto3
import cfnresponse
import os

def return_response_to_cf(event, context, status, reason):
  if event and event.get('ResponseURL'):
    cfnresponse.send(event, context, status, {}, reason=reason)

def handler(event, context):
  print("Event received:", event)
  if event.get('RequestType', '') == 'Delete':
    return_response_to_cf(event, context, cfnresponse.SUCCESS, "Delete successful")
  else:
    glue = boto3.client('glue')
    try:
      glue.start_crawler(Name=os.environ['CUR_CRAWLER_NAME'])
      return_response_to_cf(event, context, cfnresponse.SUCCESS, "Create successful")
    except Exception as e:
      return_response_to_cf(event, context, cfnresponse.FAILED, str(e))