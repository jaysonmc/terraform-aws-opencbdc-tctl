#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { CdkStack } from '../lib/cdk-stack';
import { SecretsManagerStack } from '../lib/secretsmanager-cdk-stack';
import { PipelineStack } from '../lib/pipeline-cdk-stack';

const env  = { account: '252265768975', region: 'us-east-1' };

const app = new cdk.App();

const cdkStack = new CdkStack(app, "generic-stack", {})

const secretsManager = new SecretsManagerStack(app, "secrets-manager", {
  env: env,
  githubAccessToken: cdkStack.githubAccessToken,
  region: cdkStack.region
})

const pipeline = new PipelineStack(app, "pipeline-stack", {
  env: env,
  token: secretsManager.secretVal
})