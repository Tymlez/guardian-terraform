#data "aws_eks_cluster" "this" {
#  name = var.cluster_name
#}
#
#data "aws_partition" "current" {}
#
#data "tls_certificate" "cluster" {
#  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
#}
#
#resource "aws_iam_openid_connect_provider" "oidc" {
#  client_id_list  = ["sts.amazonaws.com"]
#  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
#  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
#}
#
## 💩 this simply doesnt work
##module "eks-load-balancer-controller" {
##  source  = "lablabs/eks-load-balancer-controller/aws"
##  version = "1.0.0"
##  enabled           = true
##  argo_enabled      = false
##  argo_helm_enabled = false
##
##  cluster_name                     = var.cluster_name
##  cluster_identity_oidc_issuer     = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
##  cluster_identity_oidc_issuer_arn = aws_iam_openid_connect_provider.oidc.arn
##
##  helm_release_name = "aws-lbc-helm"
##  namespace         = "aws-lb-controller-helm"
##
##  values = yamlencode({
##    "podLabels" : {
##      "app" : "aws-lbc-helm"
##    }
##  })
##
##  helm_timeout = 240
##  helm_wait    = true
##}