import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class CdkStack extends cdk.Stack {
  
  readonly githubAccessToken: String;
  readonly paramRegion: String;
  
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const githubAccessToken = new cdk.CfnParameter(this, 'githubAccessToken', {
      type: 'String',
      description: 'Github access token',
      default: "github-access-token",
    });

    const region = new cdk.CfnParameter(this, 'region', {
      type: 'String',
      description: 'Region in which to deploy the pipeline',
      default: "us-east-1",
    });
    
    this.githubAccessToken = githubAccessToken.valueAsString;
    this.paramRegion = region.valueAsString
  }
}
