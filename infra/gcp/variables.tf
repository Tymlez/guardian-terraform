variable "stage" {
  description = "Environment stage"
}

variable "app_name" {
  description = "The name of the app being deployed (used for Domains e.g. $stage.$app_name.your-domain.com)"
}

variable "vpc_name" {}
variable "vpc_cidr" {}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_service_account" {
  type = string
}

variable "cluster_name" {
  description = "cluster_name"
}

variable "firewall_default" {}
variable "whitelisted_ips" {}
variable "gcp_local_whitelisted_ips" {}
variable "tld" {}
