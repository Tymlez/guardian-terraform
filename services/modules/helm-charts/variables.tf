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
variable "guardian_network" {}
variable "guardian_logger_level" {}

variable "custom_helm_repository" {}
variable "custom_helm_repository_username" {}
variable "custom_helm_repository_password" {}
variable "custom_helm_charts" {}
variable "custom_helm_version" {}
variable "gcp_service_account" {}

variable "enabled_newrelic" {
    default = false
}

variable "newrelic_api_key" {
    default = ""
}
variable "newrelic_license_key" {
  
}
variable "resource_configs" {
  type = map(
    object(
      {
        cpu    = string,
        memory = string,
        replicas  = number,
        autoscale = bool
      }
    )
  )

  default = {
    guardian_logger_service = {
      cpu    = "300m",
      memory = "256Mi",
      replicas  = 1,
      autoscale = false
    }
    guardian_auth_service = {
      cpu    = "300m",
      memory = "256Mi",
      replicas  = 1,
      autoscale = false
    }

     guardian_api_gateway = {
      cpu    = "300m",
      memory = "256Mi",
      replicas  = 1,
      autoscale = false
    }

    guardian_ipfs_client = {
      cpu    = "300m",
      memory = "256Mi",
      replicas  = 1,
      autoscale = false
    }

   
  }
}