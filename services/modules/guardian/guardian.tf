terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
output "hostname" {
  value = "${var.cluster_name}.${var.stage}.${var.app_name}.${var.tld}"
}