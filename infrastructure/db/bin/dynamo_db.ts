#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { DynamoDbStack } from '../lib/dynamo_db-stack';

const app = new cdk.App();
new DynamoDbStack(app, 'DynamoDbStack', {
  env: { account: process.env.CDK_DEFAULT_ACCOUNT, region: process.env.CDK_DEFAULT_REGION },
});