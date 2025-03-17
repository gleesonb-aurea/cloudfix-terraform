import json
import urllib.request
import urllib.error

SUCCESS = "SUCCESS"
FAILED = "FAILED"

def send(event, context, responseStatus, responseData, physicalResourceId=None, noEcho=False, reason=None):
    responseUrl = event.get('ResponseURL')
    
    if not responseUrl:
        return
    
    responseBody = {
        'Status': responseStatus,
        'Reason': reason or 'See the details in CloudWatch Log Stream: ' + context.log_stream_name,
        'PhysicalResourceId': physicalResourceId or context.log_stream_name,
        'StackId': event.get('StackId'),
        'RequestId': event.get('RequestId'),
        'LogicalResourceId': event.get('LogicalResourceId'),
        'NoEcho': noEcho,
        'Data': responseData
    }
    
    json_responseBody = json.dumps(responseBody)
    
    headers = {
        'content-type': '',
        'content-length': str(len(json_responseBody))
    }
    
    try:
        req = urllib.request.Request(responseUrl,
                                    data=json_responseBody.encode('utf-8'),
                                    headers=headers,
                                    method='PUT')
        response = urllib.request.urlopen(req)
        print("Status code:", response.getcode())
        print("Status message:", response.msg)
        return True
    except Exception as e:
        print("send(..) failed executing request.urlopen(..): " + str(e))
        return False