terraform {
  required_version = ">= 1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "investments-data-platform-terraform-backend"
    key    = "infra/terraform.tfstate"
    region = "ca-central-1"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "default"

  default_tags {
    tags = {
      "managed-by" = "terraform"
      "project"    = "investments-data-platform"
    }
  }
}
