#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { CdkStack } from '../lib/cdk-stack';
import { PipelineStack } from '../lib/pipeline-cdk-stack';

const app = new cdk.App();

const cdkStack = new CdkStack(app, "generic-stack", {})

const env  = { account: '252265768975', region: cdkStack.region };

const pipeline = new PipelineStack(app, "pipeline-stack", {
  env: env,
  secretName: cdkStack.secretName
})