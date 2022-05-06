output "vpc" {
  value       = google_compute_network.vpc
  description = "GCP VPC"
}

output "subnet" {
  value       = google_compute_subnetwork.subnet
  description = "GCP VPC Subnetwork"
}

output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "GCP VPC Name"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet.name
  description = "GCP Subnet Name"
}
