resource "google_container_cluster" "cluster" {
  provider = google-beta
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

  addons_config {
    gke_backup_agent_config {
      enabled = true
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "13:00"
    }
  }
  min_master_version = "1.24.4-gke.800"
}

#this is pretty buggy, for now ill leave disabled until there is create backup plan functionality in terraform
#resource "null_resource" "schedule_backup" {
#  provisioner "local-exec" {
#    command = <<-EOT
#gcloud alpha container backup-restore backup-plans create platform-cluster-backup \
#  --project=${var.gcp_project_id} \
#  --location=${var.gcp_region} \
#  --cluster=projects/${var.gcp_project_id}/locations/${var.gcp_region}/clusters/${google_container_cluster.cluster.name} \
#  --all-namespaces \
#  --include-secrets \
#  --include-volume-data
#EOT
#  }
#
#  depends_on = [
#      google_container_cluster.cluster,
#  ]
#}
