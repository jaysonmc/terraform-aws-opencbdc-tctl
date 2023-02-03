#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { PipelineStack } from '../lib/pipeline-cdk-stack';

const app = new cdk.App();

const pipeline = new PipelineStack(app, "pipeline-stack", {})