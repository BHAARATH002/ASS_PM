import json
import boto3
import base64
# import time
import requests
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")
sns = boto3.client("sns")

TABLE_NAME = "intruderLogs"
BUCKET_NAME = "intruder-images-bucket"
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:746441023300:intruder-alerts"
APP_API = "http://web-elb-1385983805.us-east-1.elb.amazonaws.com:8080/api/alerts"

def convert_epoch_to_datetime(epoch_timestamp):
    """Converts an epoch timestamp to 'YYYY-MM-DD HH:MM:SS' format."""
    return datetime.utcfromtimestamp(epoch_timestamp).strftime('%Y-%m-%d %H:%M:%S')

def lambda_handler(event, context):
    intruder_data = json.loads(event["Records"][0]["body"])
    device_id = intruder_data["device_id"]
    timestamp = intruder_data["timestamp"]
    image_data = base64.b64decode(intruder_data["image_data"])
    image_type = intruder_data["image_type"]
    image_file_size = len(image_data)
    video_data = base64.b64decode(intruder_data["video_data"])
    video_type = intruder_data["video_type"]
    video_file_size = len(video_data)
    # device_id = "device_001"
    # timestamp = int(time.time())
    # image_data = base64.b64decode("")
    # image_type = "image"
    # video_data = base64.b64decode("")
    # video_type = "video"
    
    # Store data to S3
    image_key = f"{image_type}/{device_id}/{timestamp}.jpg"
    s3.put_object(Bucket=BUCKET_NAME, Key=image_key, Body=image_data)
    video_key = f"{video_type}/{device_id}/{timestamp}.mp4"
    s3.put_object(Bucket=BUCKET_NAME, Key=video_key, Body=video_data)

    # Store log info to DynamoDB
    table = dynamodb.Table(TABLE_NAME)
    table.put_item(Item={
        "device_id": device_id,
        "timestamp": timestamp,
        "image_path": f"{image_key}",
        "video_path": f"{video_key}"
    })
    
    # Send info to APP via API
    formatted_time = convert_epoch_to_datetime(epoch_time)
    # Define the JSON payload
    payload = {
        "deviceData": [
            {
                "deviceId": device_id,
                "dataType": image_type,
                "mediaUrl": image_key,
                "fileSize": image_file_size,
                "timestamp": formatted_time
            },
            {
                "deviceId": device_id,
                "dataType": video_type,
                "mediaUrl": video_key,
                "fileSize": video_file_size,
                "timestamp": formatted_time
            }
        ],
        "deviceId": device_id,
        "alertType": "intrusion",
        "alertMessage": "intruder found.",
        "alertTitle": "Critical intruder Alert",
        "severityLevel": "high",
        "alertDatetime": formatted_time
    }
    # Set headers
    headers = {
        "Content-Type": "application/json"
    }

    # Send the POST request
    response = requests.post(url, headers=headers, data=json.dumps(payload))

    # Send notification to user via SNS topic
    message = f"🚨 Intruder detected!\nDevice: {device_id}\nTime: {timestamp}\nImage: {image_key}\nVideo: {video_key}"
    sns.publish(TopicArn=SNS_TOPIC_ARN, Message=message, Subject="🚨 Intruder Alert!")

    return {"statusCode": 200, "body": "Alert Processed"}
