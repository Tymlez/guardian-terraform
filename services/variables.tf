variable "stage" {
  description = "Environment stage"
}

variable "app_name" {
  description = "The name of the app being deployed (used for Domains e.g. $stage.$app_name.your-comain.com)"
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
variable "guardian_initial_standard_registry_balance" {
  type = number

}
variable "guardian_mongodb_persistent_size" {
  default = "50Gi"
}
variable "guardian_initial_balance" {
  type = number
}

variable "cluster_name" {
  description = "Cluster Name"
}

variable "docker_repository" {}
variable "use_ingress" {
  default = true
}
variable "tld" {}
variable "ingress_whitelisted_ips" {
  default = "{0.0.0.0/0}"
}
variable "firewall_default" {}
variable "resource_configs" {}

variable "custom_helm_repository" {}
variable "custom_helm_repository_username" {}
variable "custom_helm_repository_password" {}
variable "custom_helm_charts" {}
variable "custom_helm_version" {}
variable "custom_helm_values_yaml" {}
variable "custom_helm_ingresses" {
  default = {
    enable       = false
    service_port = ""
    service_name = ""
    service_path = ""
  }
}
# APM
variable "enabled_newrelic" {}
variable "newrelic_license_key" {}
