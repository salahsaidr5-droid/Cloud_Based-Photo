import json
import boto3
import os
import base64

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

def handler(event, context):
    bucket_name = os.environ.get('BUCKET_NAME')
    table_name = os.environ.get('TABLE_NAME')
    domain_name = os.environ.get('DOMAIN_NAME')
    table = dynamodb.Table(table_name)
    
    http_method = event.get('httpMethod')
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type'
    }

    try:
        if http_method == 'POST':
            body = json.loads(event['body'])
            file_name = body['file_name']
            file_content = base64.b64decode(body['file_content'])
            
            s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=file_content)
            
            image_url = f"https://{domain_name}/{file_name}"
            table.put_item(Item={'ID': file_name, 'URL': image_url})
            
            return {
                'statusCode': 200,
                'headers': headers,
                'body': json.dumps({'message': 'Uploaded', 'url': image_url})
            }

        elif http_method == 'GET':
            response = table.scan()
            return {
                'statusCode': 200,
                'headers': headers,
                'body': json.dumps(response.get('Items', []))
            }

        elif http_method == 'DELETE':
            params = event.get('queryStringParameters')
            file_name = params.get('file_name') if params else None
            
            if not file_name:
                return {
                    'statusCode': 400,
                    'headers': headers,
                    'body': json.dumps({'error': 'Missing file_name'})
                }
            
            s3_client.delete_object(Bucket=bucket_name, Key=file_name)
            table.delete_item(Key={'ID': file_name})
            
            return {
                'statusCode': 200,
                'headers': headers,
                'body': json.dumps({'message': 'Deleted'})
            }

        elif http_method == 'OPTIONS':
            return {
                'statusCode': 200,
                'headers': headers,
                'body': json.dumps({'message': 'OK'})
            }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({'error': str(e)})
        }