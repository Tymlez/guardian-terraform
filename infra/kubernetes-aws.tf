## This is so AWS can manage the configmap for auth on EKS (It cannot do it without a Kubernetes provider)
## YES - it is dumb that it is required - It is even dumber that I need the GCP stuff in here but otherwise when GCP is
## selected it will not work.
## These need to be set here as provider data cannot be inside of counted modules
## Until terraform allows count on providers this will continue to be messy unfortunately.

data "google_client_config" "provider" {}
data "aws_region" "current" {}

data "google_container_cluster" "cluster" {
  count    = local.build_gcp
  name     = var.cluster_name
  location = var.gcp_region
}

data "aws_eks_cluster" "cluster" {
  count = local.build_aws
  name  = module.eks_cluster.0.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = local.build_aws
  name  = module.eks_cluster.0.cluster_id
}

provider "kubernetes" {
  host                   = local.build_aws == 1 ? data.aws_eks_cluster.cluster.0.endpoint : ""
  token                  = local.build_aws == 1 ? data.aws_eks_cluster_auth.cluster.0.token : ""
  cluster_ca_certificate = local.build_aws == 1 ? base64decode(data.aws_eks_cluster.cluster.0.certificate_authority.0.data) : ""
}