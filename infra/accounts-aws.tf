provider "aws" {
  alias  = "southeast"
  region = var.aws_region
}

locals {
  build_aws = var.deploy_to_where == "aws" ? 1 : 0
}

data "aws_caller_identity" "current" {}

module "vpc" {
  count            = local.build_aws
  source           = "./modules/aws-vpc"
  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  stage            = var.stage
  app_name         = var.app_name
  cluster_name     = var.cluster_name
  firewall_default = var.firewall_default
  whitelisted_ips  = var.whitelisted_ips
}

module "aws-firewall" {
  count            = local.build_aws
  source           = "./modules/aws-firewall"
  stage             = var.stage
  firewall_default = var.firewall_default
  whitelisted_ips = var.whitelisted_ips
}

module "eks_cluster" {
  count        = local.build_aws
  source       = "./modules/eks-cluster"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.0.vpc_id
  vpc_name     = module.vpc.0.vpc_name
  subnets      = module.vpc.0.private_subnet_ids
  aws_region   = var.aws_region
  app_name     = var.app_name
  stage        = var.stage
  tld          = var.tld

  aws_user_eks = var.aws_user_eks
  aws_role_eks = var.aws_role_eks
  eks_config   = var.eks_config
}

