#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { DynamoDbStack } from '../lib/dynamo_db-stack';
import { AwsSolutionsChecks, NagSuppressions, PCIDSS321Checks } from 'cdk-nag';
import { App, Aspects } from 'aws-cdk-lib';
const app = new cdk.App();
new DynamoDbStack(app, 'dementiapp-db-stack', {
  env: { account: process.env.CDK_DEFAULT_ACCOUNT, region: process.env.CDK_DEFAULT_REGION },
});
Aspects.of(app).add(new AwsSolutionsChecks());