terraform {
  required_version = ">= 1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "investiments-data-platform-tf-backend"
    key    = "terraform.tfstate"
    region = "ca-central-1"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "default"

  default_tags {
    tags = {
      "managed-by" = "terraform"
      "project"    = "investiments-data-platform"
    }
  }
}
