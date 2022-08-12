variable "cluster_name" {}
variable "stage" {}
variable "cluster_id" {}
variable "cluster_endpoint" {}
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "region" {}
variable "master_auth" {}
variable "token" {}
variable "docker_repository" {}
variable "firewall_default" {}
variable "whitelisted_ips" {}
variable "aws_elb_sec_grp" {}

variable "guardian_access_token_secret" {}
variable "guardian_topic_id" {}
variable "guardian_operator_id" {}
variable "guardian_operator_key" {}
variable "guardian_ipfs_key" {}
variable "guardian_version" {}
variable "guardian_max_transaction_fee" {}
variable "guardian_initial_balance" {}

variable "custom_helm_repository" {}
variable "custom_helm_repository_username" {}
variable "custom_helm_repository_password" {}
variable "custom_helm_charts" {}
variable "custom_helm_version" {}
variable "gcp_service_account" {}

variable "system_schema" {}