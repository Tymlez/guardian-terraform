provider "aws" {
  alias  = "southeast"
  region = var.aws_region
}

#These need to be set here as provider data cannot be inside of counted modules

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.0.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.0.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

locals {
  build_aws = var.deploy_to_where == "aws" ? 1 : 0
}

data "aws_caller_identity" "current" {}

module "vpc" {
  count    = local.build_aws
  source   = "./modules/aws-vpc"
  vpc_name = var.stage
  stage    = var.stage
  app_name = var.app_name
  cluster_name = var.cluster_name
}

module "eks_cluster" {
  count    = local.build_aws
  source   = "./modules/eks-cluster"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.0.vpc_id
  vpc_name = module.vpc.0.vpc_name
  subnets = module.vpc.0.private_subnet_ids
  aws_region = var.aws_region
  app_name = var.app_name
  stage = var.stage
  tld = var.tld

  aws_user_eks = var.aws_user_eks
  aws_role_eks = var.aws_role_eks
}