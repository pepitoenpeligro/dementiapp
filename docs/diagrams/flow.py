from diagrams import Cluster, Diagram, Digraph
from diagrams.aws.compute import ECS, EKS, Lambda
from diagrams.aws.database import Redshift
from diagrams.aws.integration import SQS, SNS, SimpleNotificationServiceSnsEmailNotification,SimpleNotificationServiceSnsTopic
from diagrams.aws.storage import S3

from diagrams.aws.analytics import Kinesis, KinesisDataAnalytics, KinesisDataStreams


with Diagram(name="DementiApp Realtime Analytics", show=True, direction="LR" ):
        
        kinesisInput = KinesisDataStreams("InputStream")
        kinesisAnalytics = KinesisDataAnalytics("Analytics")

        topic = SNS("Anomaly Notification")
        # email = SimpleNotificationServiceSnsEmailNotification("Email")
        mobilePush = SimpleNotificationServiceSnsTopic("Push Notification")
        

        with Cluster("Post Processing"):
            output = [Lambda("Fan Out"), KinesisDataStreams("OutputStream")] 
            kinesisAnalytics >> output
        
        kinesisInput >> kinesisAnalytics
        output[0] >> topic >> mobilePush

