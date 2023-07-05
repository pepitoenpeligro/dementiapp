#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { InputStreamStack } from "../lib/input_stream-stack";
import { AwsSolutionsChecks, NagSuppressions, PCIDSS321Checks } from 'cdk-nag';
import { App, Aspects } from 'aws-cdk-lib';
const app = new cdk.App();
new InputStreamStack(app, "dementiapp-input-stream-stack", {
  env: {
    account: process.env.CDK_ACCOUNT,
    region: process.env.CDK_REGION,
  },
});

Aspects.of(app).add(new AwsSolutionsChecks());