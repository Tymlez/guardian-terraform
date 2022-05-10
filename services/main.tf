data "google_client_config" "provider" {}
data "aws_region" "current" {}

#locals {
#  build_gcp = var.deploy_to_where == "gcp" ? 1 : 0
#  build_aws = var.deploy_to_where == "aws" ? 1 : 0
#}
#get the cluster details from infra
#Do not fuck with this if you try and create them in the same state it will fail (although not immediately)
#Kubernetes & Helm on Terraform on AWS is a pain in the ass
#https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234
#https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1744
#https://github.com/hashicorp/terraform-provider-kubernetes/issues/1307#issuecomment-873089000

data "google_container_cluster" "cluster" {
  count    = local.build_gcp ? 1 : 0
  name     = var.cluster_name
  location = var.gcp_region
}

#import the EKS cluster from infra
#as above
data "aws_eks_cluster" "cluster" {
  count = local.build_aws ? 1 : 0
  name  = var.cluster_name
}

#create dependency to above
data "aws_eks_cluster_auth" "cluster-auth" {
  count      = local.build_aws ? 1 : 0
  depends_on = [data.aws_eks_cluster.cluster]
  name       = data.aws_eks_cluster.cluster.0.name
}
#I don't know why this is needed but it is
#I assume it is because you are interacting directly with Kubernetes sometimes and others via Helm
#Its not smart enough to know that it can use both

provider "kubernetes" {
  host  = local.build_gcp ? data.google_container_cluster.cluster.0.endpoint : data.aws_eks_cluster.cluster.0.endpoint
  token =  local.build_gcp ? data.google_client_config.provider.access_token : data.aws_eks_cluster_auth.cluster-auth.0.token
  cluster_ca_certificate = local.build_gcp ? base64decode(data.google_container_cluster.cluster.0.master_auth[0].cluster_ca_certificate) : base64decode(data.aws_eks_cluster.cluster.0.certificate_authority.0.data)
  client_certificate = local.build_gcp ? base64decode(data.google_container_cluster.cluster.0.master_auth[0].client_certificate) : ""
  client_key = local.build_gcp ? base64decode(data.google_container_cluster.cluster.0.master_auth[0].client_key) : ""
  load_config_file = false
}

#Aliases need to be created for each provider
#This is for each cloud as authentication requirements differ
provider "helm" {
  kubernetes {
  host  = local.build_gcp ? data.google_container_cluster.cluster.0.endpoint : data.aws_eks_cluster.cluster.0.endpoint
  token =  local.build_gcp ? data.google_client_config.provider.access_token : data.aws_eks_cluster_auth.cluster-auth.0.token
  cluster_ca_certificate = local.build_gcp ? base64decode(data.google_container_cluster.cluster.0.master_auth[0].cluster_ca_certificate) : base64decode(data.aws_eks_cluster.cluster.0.certificate_authority.0.data)
  client_certificate = local.build_gcp ? base64decode(data.google_container_cluster.cluster.0.master_auth[0].client_certificate) : ""
  client_key = local.build_gcp ? base64decode(data.google_container_cluster.cluster.0.master_auth[0].client_key) : ""
  }
}