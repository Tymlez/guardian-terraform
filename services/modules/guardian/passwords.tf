resource "random_password" "guardian_access_token_secret" {
  length  = 16
  special = false
  keepers = {
    workspace = "${terraform.workspace}"
    version   = "1" # Change when a new password is required
  }
}