import * as cdk from "aws-cdk-lib";
import { Template } from "aws-cdk-lib/assertions";
import * as InputStream from "../lib/input_stream-stack";
import { StreamMode } from "aws-cdk-lib/aws-kinesis";
import _cdkJsonRaw from "../cdk.json";
import { PrincipalWithConditions } from "aws-cdk-lib/aws-iam";

beforeEach(() => {
  jest.resetModules();
});

test("Kinesis Input Stream Created", () => {
  const app = new cdk.App();

  // WHEN
  const stack = new InputStream.InputStreamStack(app, "KinesisInputStreamTest");
  // THEN
  const template = Template.fromStack(stack);

  template.hasResourceProperties("AWS::Kinesis::Stream", {
    StreamModeDetails: { StreamMode: StreamMode.PROVISIONED },
    RetentionPeriodHours: cdk.Duration.days(1).toHours(),
    ShardCount: 1,
  });

  template.resourceCountIs("AWS::Kinesis::Stream", 1);
});
