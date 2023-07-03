#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { ZonesStack } from "../lib/zones-stack";

import { App, Aspects } from 'aws-cdk-lib';
import { AwsSolutionsChecks, NagSuppressions, PCIDSS321Checks } from 'cdk-nag';


const app = new cdk.App();
const zone_stack = new ZonesStack(app, "dementiapp-route53-zone-stack", {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});

Aspects.of(app).add(new AwsSolutionsChecks());
