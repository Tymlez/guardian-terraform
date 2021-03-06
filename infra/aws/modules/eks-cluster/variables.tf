variable "stage" {}
variable "app_name" {}
variable "tld" {}
variable "subnets" {}
variable "whitelisted_ips" {}
variable "firewall_default" {}
variable "vpc_id" {}
variable "vpc_name" {}

variable "aws_region" {}

variable "cluster_name" {
  description = "cluster_name"
}

variable "eks_config" {
  type = any
}

variable "aws_user_eks" {
  description = "User to add to EKS"
}
variable "aws_role_eks" {
  description = "Role to add to EKS"
}