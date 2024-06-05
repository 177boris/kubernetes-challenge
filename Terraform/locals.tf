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
