import * as cdk from 'aws-cdk-lib';
import * as dotenv from 'dotenv';
import * as apiGateway from '@aws-cdk/aws-apigatewayv2-alpha';
import { Construct } from 'constructs';
import { Runtime } from 'aws-cdk-lib/aws-lambda';
import { NodejsFunction } from 'aws-cdk-lib/aws-lambda-nodejs';
import { HttpLambdaIntegration } from '@aws-cdk/aws-apigatewayv2-integrations-alpha';
import 'source-map-support/register';


export class CdkTask8Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const environment = {};
    dotenv.config({ processEnv: environment });

    const cartService = new NodejsFunction(this, 'CartServiceLambda', {
      runtime: Runtime.NODEJS_18_X,
      functionName: 'cartService',
      entry: '../dist/main.js',
      environment,
      timeout: cdk.Duration.seconds(5),
      bundling: {
        externalModules: [
          'mysql',
          'mysql2',
          'pg-query-stream',
          'better-sqlite3',
          'sqlite3',
          'tedious',
          'better-sqlite3',
          'oracledb',
          '@nestjs/microservices',
          '@nestjs/microservices/microservices-module',
          '@nestjs/websockets/socket-module',
        ],
      },
    });
    
    const api = new apiGateway.HttpApi(this, 'CartApiGateway', {
      corsPreflight: {
        allowHeaders: ['*'],
        allowOrigins: ['*'],
        allowMethods: [apiGateway.CorsHttpMethod.ANY],
      },
    });

    api.addRoutes({
      path: '/{api+}',
      methods: [apiGateway.HttpMethod.ANY],
      integration: new HttpLambdaIntegration(
        'CartServiceLambdaIntegration',
        cartService,
      ),
    });

    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url || '',
    });

  }
}
