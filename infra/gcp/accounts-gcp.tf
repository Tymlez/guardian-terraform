provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.gcp_service_account
}

resource "google_project_service" "cloudresourcemanager-service" {
  project = var.gcp_project_id
  service = "cloudresourcemanager.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_project_service" "serviceusage-service" {
  project = var.gcp_project_id
  service = "serviceusage.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

resource "google_project_service" "servicecontrol-service" {
  project = var.gcp_project_id
  service = "servicecontrol.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

resource "google_project_service" "compute-service" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

resource "google_project_service" "iam-service" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]
}

resource "google_project_service" "autoscaling-service" {
  project = var.gcp_project_id
  service = "autoscaling.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [google_project_service.cloudresourcemanager-service]

}

module "platform_vpc_gcp" {
  source         = "./modules/gcp-vpc"
  vpc_name       = var.vpc_name
  vpc_cidr       = var.vpc_cidr
  subnet_name    = "platform-subnet"
  region         = var.gcp_region
  gcp_project_id = var.gcp_project_id

  depends_on = [google_project_service.cloudresourcemanager-service]

}

module "gke_cluster" {
  source       = "./modules/gke-cluster"
  cluster_name = var.cluster_name
  region       = var.gcp_region
  network      = module.platform_vpc_gcp.vpc_name
  subnetwork   = module.platform_vpc_gcp.subnet_name

  depends_on = [google_project_service.cloudresourcemanager-service]
}

module "gcp_firewall" {
  source                    = "./modules/gcp-firewall"
  firewall_default          = var.firewall_default
  gcp_local_whitelisted_ips = var.gcp_local_whitelisted_ips
  vpc_name                  = var.vpc_name
  whitelisted_ips           = var.whitelisted_ips
}