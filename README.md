# Guardian Terraform
![terraform](https://badgen.net/badge/icon/terraform?icon=terraform&label)
![terraform](https://img.shields.io/badge/Terraform-1.1.8-green)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Tymlez/guardian-terraform/graphs/commit-activity)
![Maintainer](https://img.shields.io/badge/maintainer-tymlez-blue)
![LastCommit](https://img.shields.io/github/last-commit/Tymlez/guardian-terraform)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*Supports single command deployment of the Guardian to AWS / GCP*

This repo is a complete Terraform setup for the deployment of the Guardian from [https://github.com/hashgraph/guardian](https://github.com/hashgraph/guardian).
Each deployment is by default limited to IP addresess in the configuration - this is to ensure that no one has access to the UI who shouldn't.

**PLEASE UNDERSTAND THE REQUIREMENTS FOR SECURING THIS PROPERLY BEFORE DEPLOYING PUBLICLY.**


## Steps for all Clouds
- Install terraform (https://www.terraform.io/downloads.html)
- We highly recommend using Terraform Cloud for production deployments as it handles secrets management and multiple states better than the local provisioner described in this guide

## Setup for deployment to GCP (GKE)
On GCP we deploy to GKE using an autopilot cluster, this is the simplest way to get started and leaves a lot of room
for customisation to be made according to requirements.

Steps:
- Rename `services/providers-gcp.tf_disabled` to `services/providers-gcp.tf`
- Create a service account with Owner Privileges and save the json key file.
- Enable Cloud Resource Manager API manually (This apparently cannot be done via Terraform) 
by visiting https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview 
or do `gcloud services enable cloudresourcemanager.googleapis.com`

 
## Setup for deployment to AWS (EKS)
On AWS we deploy to EKS using a managed node group of 1 x t3a.medium ON_DEMAND instance and 2 t3a.large SPOT instances by default (we recommend a larger setup for Production to handle SPOT reclamation)
Fargate is not able to be used right now due to issues with EBS, Zones and Terraform.

Steps:
- Rename `services/providers-aws.tf_disabled` to `services/providers-aws.tf`
- Create an IAM User with Admin Privileges
- Install AWS CLi and do `aws configure` - or -
- Create `[default]` profile in `~/.aws/credentials` with the following:
    - Access Key ID
    - Secret Access Key
    - Region
- On Terraform cloud simply ensure that `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` *environment* Variables are set and it will use them

## Steps for deployment to Azure (AKS)
Terraform coming soon.

## Deployment steps

1. Clone the repo
2. Copy `vars.auto.tfvars_sample` to `vars.auto.tfvars`
3. Fill out the details required in `vars.auto.tfvars` (there are notes in the file for many variables)
4. Deploy Infra first
   1. `cd infra`
   2. `cd aws` or `cd gcp`
   3. `terraform init`
   4. `terraform plan -out=infra.plan -var-file=../../vars.auto.tfvars`
   5. `terraform apply infra.plan`
5. Deploy Services
   1. `cd services`
   2. `terraform init`
   3. `terraform plan -out=services.plan -var-file=../vars.auto.tfvars`
   4. `terraform apply services.plan`
   5. Sometimes re-run steps 3 & 4 if timeouts occur as liveness probes sometimes delay.
6. Confirm Cluster setup with `kubectl get pods -o wide` 
   1. On GCP: (https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
   2. On AWS: (https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
   3. On AKS: (https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli#connect-to-the-cluster)
7. Check guardian-service is functioning with `kubectl logs -f <guardian-service-pod-name>`

## Destroy steps

- `cd services && terraform destroy -var-file=../vars.auto.tfvars`
- `cd infra/aws && terraform destroy -var-file=../../vars.auto.tfvars`
  
On Terraform cloud you will probably need to run destroy on the services first and then the infra.

When destroyed I recommend removing all plan and state files on your local machine to avoid confusion.

## Things to note & Caveats

GCP is the preferred deployment platform for this repo, GKE Autopilot just works,
and it is very low drama with excellent debugging and connectivity tools on GCP.

EKS is quite possibly the worst implementation
of Kubernetes I have ever seen, everything has a caveat or an additional piece of complexity, 
everything was an afterthought by AWS - it is working and deploys fine as described above but the flexibility
is really not there for when you want to develop it later.

There are numerous problems associated with EKS that are documented in the code
(for example, it is currently not possible to deploy Fargate profiles in EKS via Terraform), 
where possible I have added supporting documentation as to when this will be feasible.

If you are moving to Terraform Cloud (Suggested!), you will need to change `providers-aws.tf` to use
`tfe_output` instead of remote state, this is due to the ridiculous requirements of EKS needing to have a security
group added by Kubernetes when creating a load balancer if you want to protect it from outside usage.

Alternatively if someone wants to submit a PR on implementing a working WAFv2 with EKS, I would be happy to add it.

## Testing

Terraform is declarative and whilst there are some methods to develop unit tests in Terraform they are 
often used to ensure that user input is tested and rather than the code is correct. 
Most problems in Terraform stem from the Upstream providers which are often not in sync with the clouds,
this is not something that Unit tests can provide coverage for and therefore this is not a priority for us now.

## Contributing

All contributions are welcome, please open an issue if you have any questions or suggestions.
The primary goal of this repo is to provide a starting point for getting the Guardian up and running in a somewhat production
friendly manner, it will not fit every use-case but if your changes would benefit the community please consider contributing back to this repo!

Items in particular we would love help with:
- AWS Hardening (Applying ALB and WAF instead of Security groups)
- Azure Integration (AKS)
- Alibaba Integration (ACK)
- Nomad Integration
- Hashicorp Vault Integration
- Unit tests
- General updates as Terraform matures


