#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { CognitoStack } from "../lib/cognito-stack";
import { AwsSolutionsChecks, NagSuppressions, PCIDSS321Checks } from "cdk-nag";
import { App, Aspects } from "aws-cdk-lib";

const app = new cdk.App();
const backendStack = new CognitoStack(app, "dementiapp-backend-stack", {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});

NagSuppressions.addStackSuppressions(
  backendStack,
  app.node.tryGetContext("cdk-nag-supressions")
);

Aspects.of(app).add(new AwsSolutionsChecks());

app.synth();
