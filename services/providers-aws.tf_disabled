terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.28.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.1"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.14"
}

locals {
  cluster_id       = data.aws_eks_cluster.cluster.id
  cluster_endpoint = data.aws_eks_cluster.cluster.endpoint
  master_auth      = data.aws_eks_cluster.cluster.certificate_authority
  aws_elb_sec_grp  = data.terraform_remote_state.state.outputs.elb_security_group_id
  client_token     = "" #not needed in AWS
  region           = var.aws_region
}

#import the EKS cluster from infra
#as above
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

#create dependency to above
data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = [data.aws_eks_cluster.cluster]
  name       = data.aws_eks_cluster.cluster.name
}

# If using Terraform cloud backend you should use
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs
# beyond the scope of this for now - this is messy regardless but blame AWS's idiotic
# requirement for ELB to require setting security groups via Kubernetes
data "terraform_remote_state" "state" {
  backend = "local"

  config = {
    path = "../infra/aws/terraform.tfstate"
  }
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster-auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  client_certificate     = ""
  client_key             = ""
}

#Aliases need to be created for each provider
#This is for each cloud as authentication requirements differ
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster-auth.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    client_certificate     = ""
    client_key             = ""
  }
}