terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.28.0"
    }
    google = {
      source = "hashicorp/google"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.53"
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