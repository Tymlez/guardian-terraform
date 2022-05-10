#WIP
Steps for GCP

Create a service account with Editor Privileges
Go to:  https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview or do `gcloud services enable cloudresourcemanager.googleapis.com`
Enable Cloud Resource Manager API manually (This apparantly cannot be done via Terraform)
Fill out the vars.auto.tfvars
Ensure variable = "gcp"

Terraform apply