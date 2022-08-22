module "helm-charts" {
  source = "./modules/helm-charts"

  vpc_name                                   = var.vpc_name
  vpc_cidr                                   = var.vpc_cidr
  firewall_default                           = var.firewall_default
  stage                                      = var.stage
  ingress_whitelisted_ips                    = var.ingress_whitelisted_ips
  aws_elb_sec_grp                            = local.aws_elb_sec_grp
  cluster_name                               = var.cluster_name
  cluster_id                                 = local.cluster_id
  cluster_endpoint                           = local.cluster_endpoint
  master_auth                                = local.master_auth
  token                                      = local.client_token
  docker_repository                          = var.docker_repository
  guardian_access_token_secret               = var.guardian_access_token_secret
  guardian_ipfs_key                          = var.guardian_ipfs_key
  guardian_operator_id                       = var.guardian_operator_id
  guardian_operator_key                      = var.guardian_operator_key
  guardian_topic_id                          = var.guardian_topic_id
  guardian_network                           = var.guardian_network
  guardian_logger_level                      = var.guardian_logger_level
  guardian_initial_balance                   = var.guardian_initial_balance
  guardian_initial_standard_registry_balance = var.guardian_initial_standard_registry_balance
  guardian_max_transaction_fee               = var.guardian_max_transaction_fee
  guardian_version                           = var.guardian_version
  region                                     = local.region
  custom_helm_charts                         = var.custom_helm_charts
  custom_helm_version                        = var.custom_helm_version
  custom_helm_repository                     = var.custom_helm_repository
  gcp_service_account                        = var.gcp_service_account
  custom_helm_repository_username            = var.custom_helm_repository_username
  custom_helm_repository_password            = var.custom_helm_repository_password
  custom_helm_values_yaml                    = var.custom_helm_values_yaml
  custom_helm_ingresses                      = var.custom_helm_ingresses
  enabled_newrelic                           = var.enabled_newrelic
  newrelic_license_key                       = var.newrelic_license_key
  resource_configs                           = var.resource_configs
  use_ingress                                = var.use_ingress
  guardian_mongodb_persistent_size           = var.guardian_mongodb_persistent_size
}
