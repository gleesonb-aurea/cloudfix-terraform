#!/usr/bin/env python3
import boto3
import cfnresponse

def handler(event, context):
    print("Event received:", event)
    s3 = boto3.client('s3')
    def put_config_request(notification_configuration):
        try:
            response = s3.put_bucket_notification_configuration(
                Bucket=event['ResourceProperties']['BucketName'],
                NotificationConfiguration=notification_configuration
            )
            return response
        except Exception as e:
            return {'message': str(e), 'error': e}

    new_notification_config = {}
    if event['RequestType'] != 'Delete':
        new_notification_config['LambdaFunctionConfigurations'] = [{
            'Events': ['s3:ObjectCreated:*'],
            'LambdaFunctionArn': event['ResourceProperties'].get('TargetLambdaArn', 'missing arn'),
            'Filter': {'Key': {'FilterRules': [{'Name': 'prefix', 'Value': event['ResourceProperties']['ReportKey']}]}},
        }]

    if event['RequestType'] == 'Create':
        support = boto3.client('support')
        params = {
            'communicationBody': 'We need recently created CUR report named CloudFix-CUR to contain the data from the last 3 calendar months. Could you backfill the data for CloudFix-CUR?',
            'subject': 'Backfill CUR data',
            'categoryCode': 'invoices-and-reports',
            'ccEmailAddresses': [],
            'serviceCode': 'billing',
            'severityCode': 'high'
        }
        try:
            data = support.create_case(**params)
            print(data)
        except Exception as e:
            print(e, e.__traceback__)

    try:
        result = put_config_request(new_notification_config)
        cfnresponse.send(event, context, cfnresponse.SUCCESS, result)
    except Exception as error:
        cfnresponse.send(event, context, cfnresponse.FAILED, {'message': str(error), 'error': error})
        print(error)