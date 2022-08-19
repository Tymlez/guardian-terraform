variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

variable "stage" {
  description = "Environment stage"
}

variable "app_name" {
  description = "The name of the app being deployed (used for Domains e.g. $stage.$app_name.your-domain.com)"
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "aws_vpc_azs" {
  type    = list(any)
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "vpc_name" {}
variable "vpc_cidr" {}

variable "aws_user_eks" {
  description = "User to add to EKS"
}

variable "aws_role_eks" {
  description = "Role to add to EKS"
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_service_account" {
  type = string
}

variable "guardian_operator_id" {
  type = string
}

variable "guardian_operator_key" {
  type = string
}

variable "guardian_ipfs_key" {
  type = string
}

variable "guardian_topic_id" {
  type = string
}

variable "guardian_access_token_secret" {
  type = string
}

variable "guardian_static_ip" {
  type = string
}

variable "guardian_version" {
  type = string
}

variable "cluster_name" {
  description = "cluster_name"
}

variable "eks_config" {
  type = any
}

variable "firewall_default" {}
variable "whitelisted_ips" {}
variable "gcp_local_whitelisted_ips" {}
variable "docker_repository" {}
variable "tld" {}
