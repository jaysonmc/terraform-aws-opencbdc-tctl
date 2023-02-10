import { CfnOutput, Stack, StackProps, SecretValue, CfnParameter } from "aws-cdk-lib";
import { Construct } from "constructs";
import * as codepipeline from "aws-cdk-lib/aws-codepipeline";
import * as codepipeline_actions from "aws-cdk-lib/aws-codepipeline-actions";
import { CodeBuildStep, CodePipeline, CodePipelineSource } from 'aws-cdk-lib/pipelines';
import * as codebuild from "aws-cdk-lib/aws-codebuild";
import * as sm from "aws-cdk-lib/aws-secretsmanager";

export class PipelineStack extends Stack {
  
  constructor(scope: Construct, id: string, props: StackProps) {
    super(scope, id, props);
    
    const branch = 'trunk';
    const sourceOutput = new codepipeline.Artifact("SrcOutput");
    const planOutput = new codepipeline.Artifact();
    const githubToken = process.env.github_access_token ? process.env.github_access_token : ""
    const repoOwner = process.env.repo_owner ? process.env.repo_owner : ""
    
    const secret = sm.Secret.fromSecretAttributes(this, "ImportedSecret", {
      secretCompleteArn:
        `arn:aws:secretsmanager:${process.env?.region}:${this.account}:secret:${githubToken}-${process.env.github_access_token_suffix}`
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
        environmentVariables: {
          environment: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: 'dev'
          },
          s3_terraform: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.s3_terraform
          },
          lets_encrypt_email: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.lets_encrypt_email
          },
          base_domain: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.base_domain
          },
          hosted_zone_id: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.hosted_zone_id
          },
          s3_terraform_plan: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.s3_terraform_plan
          },
          s3_artifacts_builds: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.s3_artifacts_builds
          },
          cert_arn: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.cert_arn
          },
          test_controller_github_access_token: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.github_access_token
          },
          region: {
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
            value: process.env.region
          }
        }
      }
    );
    
    const pipeline = new codepipeline.Pipeline(this, "cdk-cbdcdeploy", {
      pipelineName: "cdk-cbdcdeploy",
      crossAccountKeys: false,
    });
    
    pipeline.addStage({
      stageName: "getSources",
      actions: [
        new codepipeline_actions.CodeStarConnectionsSourceAction({
          actionName: "GetGitHubTerraformSource",
          output: sourceOutput,
          owner: repoOwner,
          branch: 'trunk',
          repo: "terraform-aws-opencbdc-tctl",
          connectionArn: `arn:aws:codestar-connections:${process.env.region}:${this.account}:connection/${process.env.codestar_connectionid}`,
        })
      ]
    })
    
    pipeline.addStage({
      stageName: "Plan",
      actions: [
        new codepipeline_actions.CodeBuildAction({
          actionName: "TerraformPlan",
          project: terraformPlan,
          input: sourceOutput,
          outputs: [planOutput],
        }),
      ],
    });
    
  }
}
