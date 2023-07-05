import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";

export class OutputStreamStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const contextData = this.node.tryGetContext("environment");
    const stage: string = process.env.CDK_STAGE || "dev";

    const streamMode = contextData[stage]["streamMode"];
    const retentionPeriod = contextData[stage]["retentionPeriod"];
    const shardCount = contextData[stage]["shardCount"];
    const streamName = contextData[stage]["streamName"];

    const kinesis_stack = new cdk.aws_kinesis.Stream(this, streamName, {
      streamMode: streamMode,
      retentionPeriod: cdk.Duration.hours(retentionPeriod),
      shardCount: shardCount,
      streamName: streamName,
    });

    const tags: { [key: string]: any } = contextData[stage]["tags"];

    for (const key in tags) {
      if (tags.hasOwnProperty(key)) {
        kinesis_stack.stack.tags.setTag(key, tags[key]);
      }
    }

    new cdk.CfnOutput(this, "outputStreamArn", {
      value: kinesis_stack.streamArn,
      exportName: "outputStreamArn",
    });
  }
}
