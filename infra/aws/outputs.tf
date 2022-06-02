# This must be in the root outputs.tf so that it can be exposed for read remote state
# This is due to EKS requiring the Security Group to be passed via Kubernetes
# And this cannot be done in the same state as Terraform and Kubernetes dont play well together
output "elb_security_group_id" {
  value = module.eks_cluster.elb_security_group_id
}