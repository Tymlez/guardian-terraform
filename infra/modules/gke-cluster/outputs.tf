output "cluster" {
  value       = google_container_cluster.cluster
  description = "GKE Cluster"
}

output "cluster_id" {
  value       = google_container_cluster.cluster.id
  description = "GKE Cluster ID"
}

output "cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "GKE Cluster Name"
}

output "cluster_host" {
  value       = google_container_cluster.cluster.endpoint
  description = "GKE Cluster Host"
}

output "cluster_endpoint" {
  value       = google_container_cluster.cluster.endpoint
  description = "GKE Cluster Host"
}

output "cluster_auth" {
  value = google_container_cluster.cluster.master_auth
}