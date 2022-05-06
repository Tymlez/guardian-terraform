variable "stage" {}
variable "app_name" {}
variable "tld" {}
variable "subnets" {}

variable "vpc_id" {}
variable "vpc_name" {}

variable "aws_region" {}

variable "cluster_name" {
  description = "cluster_name"
}

variable "aws_user_eks" {
  description = "User to add to EKS"
}
variable "aws_role_eks" {
  description = "Role to add to EKS"
}