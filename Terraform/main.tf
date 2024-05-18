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

  cluster_name                             = local.name
  cluster_version                          = local.cluster_version
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 5
      desired_size = 2

      # capacity_type = "SPOT"
    }
  }

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

  # public_subnet_tags = {
  #   "kubernetes.io/role/elb" = 1
  # }

  # private_subnet_tags = {
  #   "kubernetes.io/role/internal-elb" = 1
  # }

}

##################################################################################
# additional configuration
##################################################################################

resource "aws_security_group" "node_group_db" {
  name_prefix = "${local.name}-node-group"
  description = "Allow DB access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "DB access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_iam_policy" "policy" {
  name = "${local.name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "observability" {
  name = "${local.name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:Describe*",
          "cloudwatch:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

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