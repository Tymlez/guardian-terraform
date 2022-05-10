variable "deploy_to_where" {
  description = "Where are we deploying this? Options: aws | gcp"
}
variable "stage" {
  description = "Environment stage"
}

variable "app_name" {
  description = "The name of the app being deployed (used for Domains e.g. $stage.$app_name.tymlez.com)"
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "aws_vpc_azs" {
  type = list
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
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
  description = "Cluster Name"
}


variable "docker_hub_username" {}
variable "docker_hub_password" {}
variable "docker_hub_repository" {}
variable "tld" {}