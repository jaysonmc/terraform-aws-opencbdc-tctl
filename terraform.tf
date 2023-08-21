terraform {
  required_version = "= 3.10.0"
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
