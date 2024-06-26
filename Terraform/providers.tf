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
  region = var.aws_region
  # profile = var.profile
  default_tags {
    tags = local.tags
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}
