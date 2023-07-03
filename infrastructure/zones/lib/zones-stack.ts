import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

export class ZonesStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const dev_dementiapp = new cdk.aws_route53.PublicHostedZone(scope=this, id="dev-dementiapp-com", {
      zoneName: "dev.dementiapp.com",
      comment: "Route53 Hosted zone for development environment",
    })

    const qa_dementiapp = new cdk.aws_route53.PublicHostedZone(scope=this, id="qa-dementiapp-com", {
      zoneName: "qa.dementiapp.com",
      comment: "Route53 Hosted zone for development environment"
    })
  }
}
