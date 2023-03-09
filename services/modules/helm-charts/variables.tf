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
variable "ingress_whitelisted_ips" {}
variable "aws_elb_sec_grp" {}

variable "use_ingress" {}
variable "guardian_access_token_secret" {}
variable "guardian_topic_id" {}
variable "guardian_operator_id" {}
variable "guardian_operator_key" {}
variable "guardian_ipfs_key" {}
variable "guardian_version" {}
variable "guardian_max_transaction_fee" {}
variable "guardian_initial_balance" {}
variable "guardian_initial_standard_registry_balance" {}
variable "guardian_network" {}
variable "guardian_logger_level" {}
variable "guardian_mongodb_persistent_size" {
  default = "50Gi"
}
variable "custom_helm_repository" {}
variable "custom_helm_repository_username" {}
variable "custom_helm_repository_password" {}
variable "custom_helm_charts" {}
variable "custom_helm_version" {}
variable "custom_helm_values_yaml" {}
variable "custom_helm_ingresses" {}
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
        cpu       = string,
        memory    = string,
        replicas  = number,
        autoscale = bool
      }
    )
  )

  default = {
    guardian_logger_service = {
      cpu       = "300m",
      memory    = "256Mi",
      replicas  = 1,
      autoscale = false
    }
    guardian_auth_service = {
      cpu       = "300m",
      memory    = "256Mi",
      replicas  = 1,
      autoscale = false
    }

    guardian_api_gateway = {
      cpu       = "300m",
      memory    = "256Mi",
      replicas  = 1,
      autoscale = false
    }

    guardian_ipfs_client = {
      cpu       = "300m",
      memory    = "256Mi",
      replicas  = 1,
      autoscale = false
    }

    guardian_frontend = {
      cpu       = "100m",
      memory    = "128Mi",
      replicas  = 1,
      autoscale = false
    }

    guardian_guardian_service = {
      cpu       = "400m",
      memory    = "512Mi",
      replicas  = 1,
      autoscale = false
    }

    guardian_policy_service = {
      cpu       = "400m",
      memory    = "512Mi",
      replicas  = 1,
      autoscale = false
    }

    nats = {
      cpu       = "500m",
      memory    = "256Mi",
      replicas  = 1,
      autoscale = false
    }

    guardian_worker_service = {
      cpu       = "300m",
      memory    = "256Mi",
      replicas  = 1,
      autoscale = false
    }
  }
}

variable "aws_zone" {}

variable "vault_config" {

}
variable "vault_token" {

}
variable "vault_keys" {
}
