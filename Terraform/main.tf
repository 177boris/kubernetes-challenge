data "aws_availability_zones" "available" {}

locals {
  name            = "k8s-resume-challenge"
  cluster_version = 1.27
  region          = "eu-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Project   = var.project
    Terraform = "true"
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

resource "aws_ecr_repository" "webapp" {
  name = var.project
}

##################################################################################
# EKS configuration
##################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.project
  cluster_version = "1.27"

  cluster_endpoint_public_access           = true
  # enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    green = {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t3.medium"]
    }
  }
  tags = local.tags

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
  # intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

#################################################### 

# resource "aws_ecr_repository" "microservice_a" {
#   name = "microservice-a"
# }

# resource "aws_ecr_repository" "microservice_b" {
#   name = "microservice-b"
# }

# output "ecr_repository_url_microservice_a" {
#   value = aws_ecr_repository.microservice_a.repository_url
# }

# output "ecr_repository_url_microservice_b" {
#   value = aws_ecr_repository.microservice_b.repository_url
# }

####################################################
# OLD VPC Config
####################################################
# resource "aws_vpc" "this" {
#   cidr_block           = local.vpc_cidr
#   enable_dns_hostnames = true
# }

# resource "aws_internet_gateway" "this" {
#   vpc_id = aws_vpc.this.id
# }

# resource "aws_route_table" "this" {
#   vpc_id = aws_vpc.this.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.this.id
#   }

#   route {
#     cidr_block = "10.0.0.0/16"
#     gateway_id = "local"
#   }
# }

# resource "aws_subnet" "subnet_1" {
#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = "10.0.0.0/20"
#   availability_zone       = var.availability_zone[0]
#   map_public_ip_on_launch = true
# }

# resource "aws_subnet" "subnet_2" {
#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = "10.0.16.0/20"
#   availability_zone       = var.availability_zone[1]
#   map_public_ip_on_launch = true
# }

# resource "aws_subnet" "subnet_3" {
#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = "10.0.32.0/20"
#   availability_zone       = var.availability_zone[2]
#   map_public_ip_on_launch = true
# }