import { CfnOutput, Stack, StackProps } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as codepipeline from "aws-cdk-lib/aws-codepipeline";
import * as codepipeline_actions from "aws-cdk-lib/aws-codepipeline-actions";
import { CodeBuildStep, CodePipeline, CodePipelineSource } from 'aws-cdk-lib/pipelines';
import * as secretsmanager from "@aws-cdk/aws-secretsmanager";

interface ConsumerProps extends StackProps {
}

export class PipelineCdkStack extends Stack {
  constructor(scope: Construct, id: string, props: ConsumerProps) {
    super(scope, id, props);
    
    const branch = 'trunk';
    const gitHubUsernameRepository = ' jaysonmc /terraform-aws-opencbdc-tctl';
    
    const pipeline = new codepipeline.Pipeline(this, "cdk-cbdcdeploy", {
      pipelineName: "cdk-cbdcdeploy",
      crossAccountKeys: false,
    });
    
  }
}
