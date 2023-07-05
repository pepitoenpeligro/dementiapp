import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { aws_kinesisanalyticsv2 as kinesisanalyticsv2 } from "aws-cdk-lib";
import * as lambda from "aws-cdk-lib";
import * as fs from "fs";
import * as path from "path";

export class AnalyticsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const streamToAnalyticsRole = new cdk.aws_iam.Role(
      this,
      "streamToAnalyticsRole",
      {
        assumedBy: new cdk.aws_iam.ServicePrincipal(
          "kinesisanalytics.amazonaws.com"
        ),
      }
    );

    streamToAnalyticsRole.addToPolicy(
      new cdk.aws_iam.PolicyStatement({
        resources: [
          cdk.Fn.importValue("inputStreamArn"),
          cdk.Fn.importValue("outputStreamArn"),
        ],
        actions: ["kinesis:*", "lambda:*"],
      })
    );

    const thresholdDetector = new cdk.aws_kinesisanalytics.CfnApplication(
      this,
      "KinesisAnalyticsApplication",
      {
        applicationName: "abnormality-detector",
        applicationCode: fs
          .readFileSync(path.join(__dirname, "src/stream_processor.sql"))
          .toString(),
        inputs: [
          {
            namePrefix: "SOURCE_SQL_STREAM",
            kinesisStreamsInput: {
              resourceArn: cdk.Fn.importValue("inputStreamArn"),
              roleArn: streamToAnalyticsRole.roleArn,
            },
            inputParallelism: { count: 1 },
            inputSchema: {
              recordFormat: {
                recordFormatType: "JSON",
                mappingParameters: {
                  jsonMappingParameters: { recordRowPath: "$" },
                },
              },
              recordEncoding: "UTF-8",
              recordColumns: [
                {
                  name: "client_id",
                  mapping: "$.tenant.id",
                  sqlType: "VARCHAR(32)",
                },
                {
                  name: "name",
                  mapping: "$.tenant.name",
                  sqlType: "VARCHAR(64)",
                },
                {
                  name: "tier",
                  mapping: "$.tenant.tier",
                  sqlType: "VARCHAR(32)",
                },
                {
                  name: "latitude",
                  mapping: "$.location.latitude",
                  sqlType: "DOUBLE",
                },
                {
                  name: "longitude",
                  mapping: "$.location.longitude",
                  sqlType: "DOUBLE",
                },
                {
                  name: "COL_user",
                  mapping: "$.metadata.user",
                  sqlType: "VARCHAR(64)",
                },
              ],
            },
          },
        ],
      }
    );

    thresholdDetector.node.addDependency(streamToAnalyticsRole);

    const abnormalNotificationTopic = new cdk.aws_sns.Topic(
      this,
      "AbnormalNotification",
      {
        displayName: "Abnormal detected topic",
      }
    );
    abnormalNotificationTopic.addSubscription(
      new cdk.aws_sns_subscriptions.EmailSubscription("joseant.cg@outlook.com")
    );

    const fanoutLambda = new cdk.aws_lambda.Function(
      this,
      "LambdaFanoutFunction",
      {
        runtime: cdk.aws_lambda.Runtime.PYTHON_3_8,
        handler: "fanout.handler",
        code: cdk.aws_lambda.Code.fromAsset("lib/src"),
        environment: {
          TOPIC_ARN: abnormalNotificationTopic.topicArn,
        },
      }
    );

    abnormalNotificationTopic.grantPublish(fanoutLambda);

    streamToAnalyticsRole.addToPolicy(
      new cdk.aws_iam.PolicyStatement({
        resources: [fanoutLambda.functionArn],
        actions: ["kinesis:*", "lambda:*"],
      })
    );

    const thresholdDetectorOutput =
      new cdk.aws_kinesisanalytics.CfnApplicationOutput(
        this,
        "AnalyticsAppOutput",
        {
          applicationName: "abnormality-detector",
          output: {
            name: "DESTINATION_SQL_STREAM",
            // kinesisStreamsOutput: {
            //   resourceArn: cdk.Fn.importValue("outputStreamArn"),
            //   roleArn: streamToAnalyticsRole.roleArn,
            // },
            lambdaOutput: {
              resourceArn: fanoutLambda.functionArn,
              roleArn: streamToAnalyticsRole.roleArn,
            },
            destinationSchema: {
              recordFormatType: "JSON",
            },
          },
        }
      );

    const thresholdDetectorOutputKinesis =
      new cdk.aws_kinesisanalytics.CfnApplicationOutput(
        this,
        "AnalyticsAppOutputKinesis",
        {
          applicationName: "abnormality-detector",
          output: {
            name: "DESTINATION_SQL_STREAM_GREATER_2",
            kinesisStreamsOutput: {
              resourceArn: cdk.Fn.importValue("outputStreamArn"),
              roleArn: streamToAnalyticsRole.roleArn,
            },

            destinationSchema: {
              recordFormatType: "JSON",
            },
          },
        }
      );

    thresholdDetectorOutput.node.addDependency(thresholdDetector);
  }
}
