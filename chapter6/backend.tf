terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.88.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-4632746528"
    key    = "data-engineering/6"
    region = "eu-north-1"
  }
}

provider "aws" {
  profile = "dev"
  region  = "eu-north-1"
}