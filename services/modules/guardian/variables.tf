#variable "zone_id" {
#    type = string
#    description = "Hosted Zone ID the subdomain for Guardian App"
#}

variable "stage" {
  type        = string
  description = "e.g., dev, prod"
}

variable "app_name" {
  type        = string
  description = "e.g., cohort, uon"
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
  type        = string
  description = "The version of the guardian to deploy from hashgraph/guardian"
}

variable "docker_repository" {}
variable "tld" {}
variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "master_auth" {}
variable "token" {}
