import json
import boto3
import base64

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")
sns = boto3.client("sns")

TABLE_NAME = "IntruderAlerts"
BUCKET_NAME = "intruder-images-bucket"
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:123456789012:intruder-alerts"

def lambda_handler(event, context):
    intruder_data = json.loads(event["Records"][0]["body"])
    device_id = intruder_data["device_id"]
    timestamp = intruder_data["timestamp"]
    image_data = base64.b64decode(intruder_data["image_data"])
    data_type = base64.b64decode(intruder_data["data_type"])
    
    image_key = f"{device_id}/{timestamp}.jpg"
    s3.put_object(Bucket=BUCKET_NAME, Key=image_key, Body=image_data)

    table = dynamodb.Table(TABLE_NAME)
    table.put_item(Item={
        "device_id": device_id,
        "timestamp": timestamp,
        "image_url": f"https://{BUCKET_NAME}.s3.amazonaws.com/{image_key}"
    })

    message = f"🚨 Intruder detected!\nDevice: {device_id}\nTime: {timestamp}\nImage: {image_key}"
    sns.publish(TopicArn=SNS_TOPIC_ARN, Message=message, Subject="🚨 Intruder Alert!")

    return {"statusCode": 200, "body": "Alert Processed"}
