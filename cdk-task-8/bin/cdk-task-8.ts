#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { CdkTask8Stack } from '../lib/cdk-task-8-stack';

const app = new cdk.App();
new CdkTask8Stack(app, 'CdkTask8Stack', {
  env: {
    region: 'eu-central-1',
  },
});
