import * as sm from "aws-cdk-lib/aws-secretsmanager";
import * as cdk from 'aws-cdk-lib';
import { CfnOutput, Stack, StackProps } from "aws-cdk-lib";
import { Construct } from "constructs";

export interface ConsumerProps extends StackProps {
   githubAccessToken: string
}

export class SecretsManagerStack extends Stack {
  
  readonly secretVal: string;
  
  constructor(scope: Construct, id: string, props: ConsumerProps) {
    super(scope, id, props);

    const secret = sm.Secret.fromSecretAttributes(this, "jaysosmc_github_access_token", {
      secretCompleteArn:
        `arn:aws:secretsmanager:${props.env?.region?.toString}:${cdk.Stack.of(this).account}:secret:${props.githubAccessToken}`
    });
    
    this.secretVal = secret.secretValue.toString()
  }
}