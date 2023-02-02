import { CfnOutput, Stack, StackProps, SecretValue, CfnParameter } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as codepipeline from "aws-cdk-lib/aws-codepipeline";
import * as codepipeline_actions from "aws-cdk-lib/aws-codepipeline-actions";
import { CodeBuildStep, CodePipeline, CodePipelineSource } from 'aws-cdk-lib/pipelines';
import * as codebuild from "aws-cdk-lib/aws-codebuild";
import * as sm from "aws-cdk-lib/aws-secretsmanager";

export interface ConsumerProps extends StackProps {
   secretName: string
}

export class PipelineStack extends Stack {
  
  constructor(scope: Construct, id: string, props: ConsumerProps) {
    super(scope, id, props);
    
    const branch = 'trunk';
    const gitHubUsernameRepository = ' jaysonmc/terraform-aws-opencbdc-tctl';
    
    const s3_terraform = new CfnParameter(this, 's3_terraform', {
      type: 'String',
      description: 'Location of Terraform install',
      default: "",
    });
    
    // List of required env vars
    /*
    lets_encrypt_email
    base_domain
    s3_terraform_plan
    hosted_zone_id
    test_controller_github_access_token // maybe?
    s3_artifacts_builds
    cert_arn
    */
    
    const secret = sm.Secret.fromSecretAttributes(this, "ImportedSecret", {
      secretCompleteArn:
        `arn:aws:secretsmanager:${props.env?.region}:${props.env?.account}:secret:${props.secretName}`
    });
    
    const codeBuildSource = new codebuild.GitHubSourceCredentials(
      this,
      "CodeBuildGitHub",
      { accessToken: secret.secretValue }
    );
    
    const pipeline = new codepipeline.Pipeline(this, "cdk-cbdcdeploy", {
      pipelineName: "cdk-cbdcdeploy",
      crossAccountKeys: false,
    });
    
    const terraformPlan = new codebuild.PipelineProject(
      this,
      "TerraformPlan",
      {
        environment: {
          buildImage: codebuild.LinuxBuildImage.STANDARD_5_0,
          privileged: false,
          computeType: codebuild.ComputeType.MEDIUM,
        },
        buildSpec: codebuild.BuildSpec.fromSourceFilename("plan-buildspec.yml"),
        environmentVariables:{
          //{"environment":"dev"}
        }
      }
    );

  }
}
