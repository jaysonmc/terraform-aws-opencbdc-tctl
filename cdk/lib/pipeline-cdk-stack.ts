import { CfnOutput, Stack, StackProps, SecretValue } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as codepipeline from "aws-cdk-lib/aws-codepipeline";
import * as codepipeline_actions from "aws-cdk-lib/aws-codepipeline-actions";
import { CodeBuildStep, CodePipeline, CodePipelineSource } from 'aws-cdk-lib/pipelines';
import * as codebuild from "aws-cdk-lib/aws-codebuild";
import * as sm from "aws-cdk-lib/aws-secretsmanager";

export interface ConsumerProps extends StackProps {
   token: string
}

export class PipelineStack extends Stack {
  
  constructor(scope: Construct, id: string, props: ConsumerProps) {
    super(scope, id, props);
    
    const branch = 'trunk';
    const gitHubUsernameRepository = ' jaysonmc/terraform-aws-opencbdc-tctl';
    
    const codeBuildSource = new codebuild.GitHubSourceCredentials(
      this,
      "CodeBuildGitHub",
      { accessToken: SecretValue.secretsManager(props.token)}
    );
    
    const pipeline = new codepipeline.Pipeline(this, "cdk-cbdcdeploy", {
      pipelineName: "cdk-cbdcdeploy",
      crossAccountKeys: false,
    });

  }
}
