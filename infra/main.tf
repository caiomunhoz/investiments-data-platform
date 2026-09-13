terraform {
    required_version = ">= 1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "investiments-data-platform-tf-backend"
    key = "terraform.tfstate"
    region="us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "managed-by" = "terraform"
      "project" = "investiments-data-platform"
    }
  }
}
