"""fanout.py reads from kinesis analytic output and fans out to SNS """

import base64
import json
import os
from datetime import datetime

import boto3

sns = boto3.client("sns")


def handler(event, context):
    payload = event["records"][0]["data"]
    data_dump = base64.b64decode(payload).decode("utf-8")
    data = json.loads(data_dump)


    item = {
        "client_id": data["client_id"],
        "latitude": data["latitude"],
        "longitude": data["longitude"],
        "anomaly": data["ANOMALY_SCORE"],
        "inspectedAt": str(datetime.now())
    }
    
    sns.publish(
        TopicArn=os.environ["TOPIC_ARN"],
        Message=json.dumps(item)
    )

    return {"statusCode": 200, "body": json.dumps(item)}