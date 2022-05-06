provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  credentials = var.gcp_service_account
}

locals {
  build_gcp = var.deploy_to_where == "gcp" ? 1 : 0
}

resource "google_project_service" "cloudresourcemanager-service" {
  project = var.gcp_project_id
  service = "cloudresourcemanager.googleapis.com"
  count = local.build_gcp

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_project_service" "serviceusage-service" {
  project = var.gcp_project_id
  service = "serviceusage.googleapis.com"
  count = local.build_gcp

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

resource "google_project_service" "servicecontrol-service" {
  project = var.gcp_project_id
  service = "servicecontrol.googleapis.com"
  count = local.build_gcp

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

resource "google_project_service" "compute-service" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"
  count = local.build_gcp

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

resource "google_project_service" "iam-service" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"
  count = local.build_gcp

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]
}

resource "google_project_service" "autoscaling-service" {
  project = var.gcp_project_id
  service = "autoscaling.googleapis.com"
  count = local.build_gcp

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

module "platform_vpc_gcp" {
  count          = local.build_gcp
  source         = "./modules/gcp-vpc"
  vpc_name       = "platform-vpc"
  subnet_name    = "platform-subnet"
  region         = var.gcp_region
  gcp_project_id = var.gcp_project_id

  depends_on = [google_project_service.cloudresourcemanager-service]
}

module "gke_cluster" {
  count        = local.build_gcp
  source       = "./modules/gke-cluster"
  cluster_name = var.cluster_name
  region       = var.gcp_region
  network      = module.platform_vpc_gcp.0.vpc_name
  subnetwork   = module.platform_vpc_gcp.0.subnet_name

  depends_on = [google_project_service.cloudresourcemanager-service]
}