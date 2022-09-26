provider "aws" {
  alias  = "southeast"
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source           = "./modules/aws-vpc"
  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  stage            = var.stage
  app_name         = var.app_name
  cluster_name     = var.cluster_name
  firewall_default = var.firewall_default
  whitelisted_ips  = var.whitelisted_ips
  aws_vpc_config   = var.aws_vpc_config
}

#this is currently not in use (security groups are used instead)
#this is because AWS makes it next to impossible to get it working with a K8s generated ALB
#that then needs to be attached to the generated ALB
module "aws-firewall" {
  source           = "./modules/aws-firewall"
  stage            = var.stage
  firewall_default = var.firewall_default
  whitelisted_ips  = var.whitelisted_ips
}

module "eks_cluster" {
  source           = "./modules/eks-cluster"
  cluster_name     = var.cluster_name
  vpc_id           = module.vpc.vpc_id
  vpc_name         = module.vpc.vpc_name
  subnets          = module.vpc.private_subnet_ids
  whitelisted_ips  = var.whitelisted_ips
  firewall_default = var.firewall_default
  aws_region       = var.aws_region
  app_name         = var.app_name
  stage            = var.stage
  tld              = var.tld

  aws_user_eks = var.aws_user_eks
  aws_role_eks = var.aws_role_eks
  eks_config   = var.eks_config
}

