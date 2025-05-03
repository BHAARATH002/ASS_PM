import json
import boto3
import base64
import time
import requests
from datetime import datetime

# MQTT configuration
MQTT_BROKER = "a2snp5xlwnixk9-ats.iot.us-east-1.amazonaws.com"
MQTT_TOPIC = "sdk/test/python1"
AWS_REGION = "us-east-1"

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")
sns = boto3.client("sns")

TABLE_NAME = "intruderLogs"
BUCKET_NAME = "intruder-images-bucket"
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:746441023300:intruder-alerts"
APP_API = "http://web-elb-1385983805.us-east-1.elb.amazonaws.com:8080"

def get_token(iot_client, device_id):
    # Get tokem the POST request
    # Define the JSON payload
    decoded_bytes = base64.b64decode('SW9UTWFjaGluZQ==')
    decoded_password = decoded_bytes.decode('utf-8')
    payloadUserInfo = {
        "username": "IoTMachine",
        "password": decoded_password
    }
    # Set headers
    headersToken = {
        "Content-Type": "application/json"
    }
    try:
        responseToken = requests.post(f"{APP_API}/api/users/login", headers=headersToken, data=json.dumps(payloadUserInfo), timeout=10)
        responseToken.raise_for_status()
        response_json = responseToken.json()
        token = response_json.get('data')
        print(f"API response: {responseToken.status_code}, {responseToken.text}, token: {token}")
        return token
    except requests.exceptions.RequestException as e:
        print(f"StatusCode: E007, ERROR:{str(e)}")
        error_message = f"Invalid APP API Autnentication: {device_id}"
        publish_mqtt_response(iot_client, error_message, "E007")
        return {"statusCode": 500, "error": error_message}

def convert_epoch_to_datetime(epoch_timestamp):
    """Converts an epoch timestamp to 'YYYY-MM-DD HH:MM:SS' format."""
    return datetime.utcfromtimestamp(epoch_timestamp).strftime('%Y-%m-%d %H:%M:%S')

def publish_mqtt_response(iot_client, message, status):
    """Publishes a response message to the MQTT topic."""
    try:
        iot_client.publish(
            topic=MQTT_TOPIC,
            payload=json.dumps({"message": message, "status": status}),
            qos=1
        )
        print(f"MQTT Response Published: {message}")
    except Exception as e:
        print(f"Error publishing MQTT response: {str(e)}")

def lambda_handler(event, context):
    iot_client = boto3.client('iot-data')
    print(f"Received event: {event}")
    
    device_id = event.get("device_id")
    timestamp = event.get("timestamp")
    image_data = base64.b64decode(event.get("image_data"))
    image_type = event.get("image_type")
    image_file_size = len(image_data)
    video_key = event.get("video_data")
    video_type = event.get("video_type")
    video_file_size = event.get("video_file_size")
    
    # Validate required fields
    if not device_id or not timestamp or not image_data:
        print(f"StatusCode: E001, ERROR: Missing required fields: device_id, timestamp, or image_data.")
        error_message = "Missing required fields: device_id, timestamp, or image_data."
        publish_mqtt_response(iot_client, error_message, "E001")
        return {"statusCode": 400, "error": error_message}
    
    print("Event information received and validated.")
    
    # Store data to S3
    image_key = f"image/{device_id}/{timestamp}.{image_type}"
    try:
        s3.put_object(Bucket=BUCKET_NAME, Key=image_key, Body=image_data)
        print(f"Image stored at S3: {image_key}")
    except Exception as e:
        print(f"StatusCode: E003, ERROR: {str(e)}")
        error_message = f"Failed to store image in S3: {image_key}"
        publish_mqtt_response(iot_client, error_message, "E003")
        return {"statusCode": 500, "error": error_message}

    # Store log info to DynamoDB
    try:
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(Item={
            "device_id": str(device_id),
            "timestamp": timestamp,
            "image_path": image_key,
            "video_path": video_key or "N/A"
        })
        print(f"Log stored in DynamoDB: {device_id}, {timestamp}")
    except Exception as e:
        print(f"StatusCode: E004, ERROR:{str(e)}")
        error_message = f"Failed to store log in DynamoDB: {device_id}"
        publish_mqtt_response(iot_client, error_message, "E004")
        return {"statusCode": 500, "error": error_message}

    # Get Token for APP API
    auth_token = get_token(iot_client, device_id)
    # Send info to APP via API
    formatted_time = convert_epoch_to_datetime(timestamp)
    # Define the JSON payload
    payload = {
        "deviceData": [
            {
                "dataType": image_type,
                "mediaUrl": image_key,
                "fileSize": image_file_size,
                "timestamp": formatted_time
            },
            {
                "dataType": video_type,
                "mediaUrl": video_key,
                "fileSize": video_file_size,
                "timestamp": formatted_time
            }
        ],
        "deviceId": device_id,
        "alertMessage": "Intruder found. Please response!",
        "alertTitle": "Critical intruder Alert",
        "severityLevel": "high",
        "alertDatetime": formatted_time
    }
    print(f"Payload: {payload}")
    # Set headers
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {auth_token}"
    }
    # Send the POST request
    try:
        response = requests.post(f"{APP_API}/api/alerts", headers=headers, data=json.dumps(payload), timeout=10)
        response.raise_for_status()
        print(f"API response: {response.status_code}, {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"StatusCode: E005, ERROR:{str(e)}")
        error_message = f"Failed to send alert to APP API: {device_id}"
        publish_mqtt_response(iot_client, error_message, "E005")
        return {"statusCode": 500, "error": error_message}

    # Send notification to user via SNS topic
    message = f"🚨 Intruder detected!\nDevice: {device_id}\nTime: {formatted_time} ({timestamp})\nImage: {image_key}\nVideo: {video_key}"
    try:
        sns.publish(TopicArn=SNS_TOPIC_ARN, Message=message, Subject="🚨 Intruder Alert!")
        print(f"Notification sent via SNS: {message}")
    except Exception as e:
        print(f"StatusCode: E006, ERROR:{str(e)}")
        error_message = f"Failed to send SNS notification: {device_id}"
        publish_mqtt_response(iot_client, error_message, "E006")
        return {"statusCode": 500, "error": error_message}

    # Publish success response to MQTT
    success_message = f"✅ Message processed successfully for device {device_id}."
    publish_mqtt_response(iot_client, success_message, "200")
    print(f"Response published to MQTT topic using boto3: {MQTT_TOPIC}")

    return {
        'statusCode': 200,
        'body': json.dumps(f'Message processed and response published for Device: {device_id}!')
    }
