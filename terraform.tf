terraform {
  required_version = "= 1.2.8"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.4"
    }
  }
}
