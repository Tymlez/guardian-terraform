provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.gcp_service_account
}

data "google_client_config" "current" {}

locals {
  build_gcp        = var.deploy_to_where == "gcp" ? true : false
  build_aws        = var.deploy_to_where == "aws" ? true : false
  cluster_id       = local.build_gcp ? data.google_container_cluster.cluster.0.id : data.aws_eks_cluster.cluster.0.id
  cluster_endpoint = local.build_gcp ? data.google_container_cluster.cluster.0.endpoint : data.aws_eks_cluster.cluster.0.endpoint
  master_auth      = local.build_gcp ? data.google_container_cluster.cluster.0.master_auth : data.aws_eks_cluster.cluster.0.certificate_authority
  region           = local.build_gcp ? var.gcp_region : var.aws_region
}



module "guardian" {
  source       = "./modules/guardian"
  stage        = var.stage
  app_name     = var.app_name
  cluster_name = var.cluster_name
  tld          = var.tld

  docker_hub_repository        = var.docker_hub_repository
  guardian_access_token_secret = var.guardian_access_token_secret
  guardian_ipfs_key            = var.guardian_ipfs_key
  guardian_operator_id         = var.guardian_operator_id
  guardian_operator_key        = var.guardian_operator_key
  guardian_static_ip           = var.guardian_static_ip
  guardian_topic_id            = var.guardian_topic_id
  guardian_version             = var.guardian_version
  cluster_endpoint             = local.cluster_endpoint
  master_auth                  = local.master_auth
  token                        = data.google_client_config.current.access_token
}

#module "guardian-repo" {
#  source = "./modules/guardian-repo"
#  guardian_version = var.guardian_version
#}

#module "registry" {
#  source = "./modules/registry"
#  docker_hub_password   = var.docker_hub_password
#  docker_hub_repository = var.docker_hub_repository
#  docker_hub_username   = var.docker_hub_username
#
#  depends_on = [module.guardian-repo]
#}
#module "kubernetes" {
#  source = "./modules/kubernetes"
#  cluster_name = var.cluster_name
#  region = local.region
#}

module "helm-charts" {
  source = "./modules/helm-charts"

  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  cluster_name     = var.cluster_name
  cluster_id       = local.cluster_id
  cluster_endpoint = local.cluster_endpoint

  master_auth                  = local.master_auth
  token                        = data.google_client_config.current.access_token
  docker_hub_repository        = var.docker_hub_repository
  guardian_access_token_secret = var.guardian_access_token_secret
  guardian_ipfs_key            = var.guardian_ipfs_key
  guardian_operator_id         = var.guardian_operator_id
  guardian_operator_key        = var.guardian_operator_key
  guardian_topic_id            = var.guardian_topic_id
  region                       = local.region

  depends_on = [
    #    module.registry,
    data.google_container_cluster.cluster,
    #    module.guardian-repo,
    module.guardian,
    #    module.kubernetes
  ]



  deploy_to_where = var.deploy_to_where
}