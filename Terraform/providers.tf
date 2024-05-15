##################################################################################
# PROVIDERS
##################################################################################

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "k8s-challenge-remote-0424"
    key            = "eu-west-2/current.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "k8s-challenge-remote-state-ddb"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "Lanre"
  default_tags {
    tags = local.tags
  }
}
