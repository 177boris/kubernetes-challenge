locals {
  name            = var.project
  cluster_version = var.cluster_version
  region          = var.aws_region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Project     = var.project
    Terraform   = "true"
    Environment = "Dev"
  }
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-${local.cluster_version}-v*"]
  }
}

data "aws_availability_zones" "available" {}

resource "aws_ecr_repository" "webapp" {
  name = var.project
}

##################################################################################
# EKS configuration
##################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                             = local.name
  cluster_version                          = local.cluster_version
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
    amazon-cloudwatch-observability = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    # coredns = {
    #   most_recent = true
    # }
    # adot = {
    #   most_recent = true
    # }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    green = {
      name = "green-node-group"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    blue = {
      name = "blue-node-group"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
    #     iam_role_additional_policies = [
    # "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    # ]
  }
}

resource "aws_iam_role_policy_attachment" "CloudwatchAgent" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = each.value.iam_role_name
}

##################################################################################
# VPC configuration
##################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = var.enable_nat_gw
  single_nat_gateway = var.single_nat_gw

  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = var.map_public_ip

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

}
