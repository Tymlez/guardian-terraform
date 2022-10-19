variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

variable "stage" {
  description = "Environment stage"
}

variable "app_name" {
  description = "The name of the app being deployed (used for Domains e.g. $stage.$app_name.abc.com)"
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "aws_zone" {
  default = "ap-southeast-2a"
}

variable "aws_vpc_azs" {
  type    = list(any)
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "vpc_name" {
  description = "The name of the VPC"
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC"
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
variable "guardian_network" {
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

variable "docker_repository" {}
variable "tld" {}
variable "use_ingress" {
  default = true
}

variable "vault_config" {
  type = object({
    self_host       = bool
    vault_provider  = string,
    vault_url       = string,
    vault_workspace = string
    }
  )
  default = {
    self_host       = true
    vault_provider  = "hashicorp"
    vault_url       = "http://vault:8200"
    vault_workspace = "guardian"
  }
}

variable "vault_token" {
  default = "na"
}
