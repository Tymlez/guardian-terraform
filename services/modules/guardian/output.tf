# Note: Following resources are to be deprecated
output "guardian_service_api_key" {
  value = random_password.guardian_access_token_secret.result
}

output "guardian_operator_id" {
  value = var.guardian_operator_id
}

output "guardian_operator_key" {
  value = var.guardian_operator_key
}

output "guardian_ipfs_key" {
  value = var.guardian_ipfs_key
}

output "guardian_topic_id" {
  value = var.guardian_topic_id
}