#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { AnalyticsStack } from "../lib/analytics-stack";
import { AwsSolutionsChecks, NagSuppressions, PCIDSS321Checks } from "cdk-nag";
import { App, Aspects } from "aws-cdk-lib";

const app = new cdk.App();
const analyticsStack = new AnalyticsStack(app, "dementiapp-kinesis-analytics", {
  env: {
    account: process.env.CDK_ACCOUNT,
    region: process.env.CDK_REGION,
  },
});

Aspects.of(app).add(new AwsSolutionsChecks());

NagSuppressions.addStackSuppressions(
  analyticsStack,
  app.node.tryGetContext("cdk-nag-supressions")
);

app.synth();
