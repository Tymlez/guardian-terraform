provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.gcp_service_account
}

data "google_client_config" "current" {}

locals {
  cluster_id       = local.build_gcp ? data.google_container_cluster.cluster.0.id : data.aws_eks_cluster.cluster.0.id
  cluster_endpoint = local.build_gcp ? data.google_container_cluster.cluster.0.endpoint : data.aws_eks_cluster.cluster.0.endpoint
  master_auth      = local.build_gcp ? data.google_container_cluster.cluster.0.master_auth : data.aws_eks_cluster.cluster.0.certificate_authority
  region           = local.build_gcp ? var.gcp_region : var.aws_region
}



module "helm-charts" {
  source = "./modules/helm-charts"

  vpc_name                     = var.vpc_name
  vpc_cidr                     = var.vpc_cidr
  vpc_id                       = data.aws_eks_cluster.cluster.0.vpc_config.0.vpc_id
  firewall_default             = var.firewall_default
  stage                        = var.stage
  whitelisted_ips              = var.whitelisted_ips
  cluster_name                 = var.cluster_name
  cluster_id                   = local.cluster_id
  cluster_endpoint             = local.cluster_endpoint
  deploy_to_where              = var.deploy_to_where
  master_auth                  = local.master_auth
  token                        = data.google_client_config.current.access_token
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
  waf_arn                      = data.aws_wafv2_web_acl.wafv2.0.arn

  depends_on = [
    data.google_container_cluster.cluster
  ]






}