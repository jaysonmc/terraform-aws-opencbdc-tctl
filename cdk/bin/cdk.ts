#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { CdkStack } from '../lib/cdk-stack';
import { SecretsManagerStack } from '../lib/secretsmanager-cdk-stack';

const app = new cdk.App();

const cdkStack = new CdkStack(app, "generic-stack", {})

const secretsManager = new SecretsManagerStack(app, "secrets-manager", {
  githubAccessToken: cdkStack.githubAccessToken,
  region: cdkStack.region
})
