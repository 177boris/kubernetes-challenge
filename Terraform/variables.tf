##################################################################################
# VARS
##################################################################################

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "project" {
  type    = string
  default = "k8s-resume-challenge"
}

variable "availability_zone" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}