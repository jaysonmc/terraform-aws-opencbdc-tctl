# Welcome to your CDK TypeScript project

This is a blank project for CDK development with TypeScript.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `cdk deploy`      deploy this stack to your default AWS account/region
* `cdk diff`        compare deployed stack with current state
* `cdk synth`       emits the synthesized CloudFormation template

# The following environment variables must be set locally to run cdk deploy

- github\_access\_token (including 6 character suffix)
- region
- cert_arn
- s3\_artifacts\_builds
- s3\_terraform\_plan
- hosted\_zone\_id
- base_domain
- lets\_encrypt\_email
- s3_terraform