terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.64.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.64.0"
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

data "google_client_config" "provider" {}


locals {
  cluster_id       = data.google_container_cluster.cluster.id
  cluster_endpoint = data.google_container_cluster.cluster.endpoint
  master_auth      = data.google_container_cluster.cluster.master_auth
  client_token     = data.google_client_config.provider.access_token
  aws_elb_sec_grp  = "na" #not needed for GCP, cannot be blank
  region           = var.gcp_region
}

data "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.gcp_region
}

provider "kubernetes" {
  host                   = data.google_container_cluster.cluster.endpoint
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
  client_certificate     = base64decode(data.google_container_cluster.cluster.master_auth[0].client_certificate)
  client_key             = base64decode(data.google_container_cluster.cluster.master_auth[0].client_key)
}

#Aliases need to be created for each provider
#This is for each cloud as authentication requirements differ
provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.cluster.endpoint
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
    client_certificate     = base64decode(data.google_container_cluster.cluster.master_auth[0].client_certificate)
    client_key             = base64decode(data.google_container_cluster.cluster.master_auth[0].client_key)
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.gcp_service_account
}
