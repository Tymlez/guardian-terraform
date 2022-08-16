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
  type    = list(any)
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

variable "guardian_network" {
  type = string
}

variable "guardian_logger_level" {
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

variable "guardian_max_transaction_fee" {
  type = number
}

variable "guardian_initial_balance" {
  type = number
}

variable "cluster_name" {
  description = "Cluster Name"
}

variable "docker_repository" {}
variable "tld" {}
variable "whitelisted_ips" {}
variable "firewall_default" {}

variable "custom_helm_repository" {}
variable "custom_helm_repository_username" {}
variable "custom_helm_repository_password" {}
variable "custom_helm_charts" {}
variable "custom_helm_version" {}

variable "system_schema" {}

variable "enabled_newrelic" {

}
variable "newrelic_license_key" {

}