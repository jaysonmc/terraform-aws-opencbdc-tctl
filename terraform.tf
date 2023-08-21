terraform {
  required_version = "= 1.3.7"
  backend "s3" {
    bucket = "jaysosmc-opencbdc-artifacts"
    key    = "test.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.4"
    }
  }
}
