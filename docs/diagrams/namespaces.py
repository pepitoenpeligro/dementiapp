from diagrams import Cluster, Diagram, Digraph
from diagrams.aws.compute import ECS, EKS, Lambda
from diagrams.aws.database import Redshift
from diagrams.aws.integration import SQS, SNS, SimpleNotificationServiceSnsEmailNotification,SimpleNotificationServiceSnsTopic
from diagrams.aws.storage import S3


from diagrams.k8s.group import Namespace
from diagrams.k8s.compute import Pod

from diagrams.aws.analytics import Kinesis, KinesisDataAnalytics, KinesisDataStreams


with Diagram(name="Isolation by namespaces",  direction="TB" ):

    with Cluster("k8s cluster"):
        Namespace(label="organization 1")
        Namespace(label="organization 2")
        Namespace(label="organization 3")