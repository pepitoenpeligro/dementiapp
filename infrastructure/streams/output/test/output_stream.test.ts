import * as cdk from 'aws-cdk-lib';
import { Template } from 'aws-cdk-lib/assertions';
import * as OutputStream from '../lib/output_stream-stack';
import { StreamMode } from 'aws-cdk-lib/aws-kinesis';

test('Kinesis Output Stream Created', () => {
    const app = new cdk.App();

    const stack = new OutputStream.OutputStreamStack(app, 'KinesisOutputStreamTest');
    const template = Template.fromStack(stack);

    template.hasResourceProperties('AWS::Kinesis::Stream', {
        StreamModeDetails: { StreamMode : StreamMode.PROVISIONED },
        RetentionPeriodHours: cdk.Duration.days(1).toHours(),
        ShardCount: 1
    });

    template.resourceCountIs("AWS::Kinesis::Stream", 1);
});
