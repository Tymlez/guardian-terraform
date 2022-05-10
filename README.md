#Guardian Terraform

*Supports single command deployment of the Guardian to AWS / GCP*

This repo is a complete Terraform setup for the deployment of the Guardian from hashgraph/guardian.

##Steps for all Clouds
- Prepare credentials for Docker Hub
- We highly recommend using Terraform Cloud for production deployments as it handles secrets management and multiple states better than the local provisioner described in this guide

##Steps for deployment to GCP (GKE)
- Ensure that `deploy_to_where = "gcp"` is set in the `vars.auto.tfvars` file
- Create a service account with Editor Privileges
- Enable Cloud Resource Manager API manually (This apparently cannot be done via Terraform) by visiting https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview or do `gcloud services enable cloudresourcemanager.googleapis.com`

 
##Steps for deployment to AWS (EKS)
- Ensure that `deploy_to_where = "aws"` is set in the `vars.auto.tfvars` file
- Create an IAM User with Admin Privileges

##Steps for deployment to Azure (AKS)
Terraform coming soon.
Until then you can apply the helm charts from `services/modules/helm-charts/charts` directly to an existing AKS Cluster

##Deployment steps

1. Clone the repo
2. Copy `vars.auto.tfvars_sample` to `vars.auto.tfvars`
3. Fill out the details required in `vars.auto.tfvars`
4. Run `terraform init`
5. Deploy Infra first
   1. `cd infra`
   2. `terraform plan -out=infra.plan -var-file=../vars.auto.tfvars`
   3. `terraform apply infra.plan`
6. Deploy Services
   1. `cd services`
   2. `terraform plan -out=services.plan -var-file=../vars.auto.tfvars`
   3. `terraform apply services.plan`
7. Confirm Cluster setup with `kubectl get pods -o wide` 
   1. On GCP: (https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
   2. On AWS: (https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
   3. On AKS: (https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#connect-to-the-cluster)
8. Check guardian-service is functioning with `kubectl logs -f <guardian-service-pod-name>`

##Destroy steps

- On GCP it should be as simple as  `cd infra && terraform destroy -var-file=../vars.auto.tfvars`
- On AWS you have to manually delete the Load Balancer that EKS created (it does this outside of Terraform 
via the Helm charts meaning Terraform cannot track it in the state file which is wildly unhelpful)
- Then you can destroy with `cd infra && terraform destroy -var-file=../vars.auto.tfvars`

On Terraform cloud you will probably need to run destroy on the services first and then the infra.

When destroyed I recommend removing all plan and state files on your local machine to avoid confusion.

##Things to note & Caveats

GCP is the preferred deployment platform for this repo, trust us when we say 
EKS sounds like it is all singing and all dancing but it is quite possibly the worst implementation
of Kubernetes I have ever seen.

