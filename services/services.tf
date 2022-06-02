module "helm-charts" {
  source = "./modules/helm-charts"

  vpc_name                     = var.vpc_name
  vpc_cidr                     = var.vpc_cidr
  firewall_default             = var.firewall_default
  stage                        = var.stage
  whitelisted_ips              = var.whitelisted_ips
  aws_elb_sec_grp              = local.aws_elb_sec_grp
  cluster_name                 = var.cluster_name
  cluster_id                   = local.cluster_id
  cluster_endpoint             = local.cluster_endpoint
  master_auth                  = local.master_auth
  token                        = local.client_token
  docker_repository            = var.docker_repository
  guardian_access_token_secret = var.guardian_access_token_secret
  guardian_ipfs_key            = var.guardian_ipfs_key
  guardian_operator_id         = var.guardian_operator_id
  guardian_operator_key        = var.guardian_operator_key
  guardian_topic_id            = var.guardian_topic_id
  guardian_initial_balance     = var.guardian_initial_balance
  guardian_max_transaction_fee = var.guardian_max_transaction_fee
  guardian_version             = var.guardian_version
  region                       = local.region

}