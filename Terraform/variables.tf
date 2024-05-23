##################################################################################
# VARS
##################################################################################
variable "project" {
  type    = string
  default = "k8s-resume-challenge"
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "profile" {
  type    = string
  default = "Lanre"
}

variable "cluster_version" {
  type        = string
  default     = "1.29"
  description = "kubernetes cluster version"
}

variable "availability_zone" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "enable_nat_gw" {
  type    = bool
  default = true
}

variable "single_nat_gw" {
  type    = bool
  default = true
}

variable "map_public_ip" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}
