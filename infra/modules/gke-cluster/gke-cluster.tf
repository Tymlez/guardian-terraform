resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region

  ip_allocation_policy { #workaround for a bug in latest version
  }

  network    = var.network
  subnetwork = var.subnetwork

  # Enable Autopilot for this cluster
  enable_autopilot = true

  # Without this, terraform will keep detecting changes to this property
  vertical_pod_autoscaling {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "13:00"
    }
  }

}


