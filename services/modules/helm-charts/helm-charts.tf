resource "helm_release" "mongodb" {
  name       = "mongodb"
  chart      = "mongodb"
  repository = "https://charts.bitnami.com/bitnami"
  version    = "10.30.0"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/mongodb/values.yaml")}",
    "${file("${path.root}/modules/helm-charts/charts/mongodb/aws-pvc.yaml")}", #required for EKS Bullshit, shouldn't affect other clouds
  ]

  set {
    name  = "auth.enabled"
    value = "false"
  }
}

## 💩
## This literally doesn't work with Helm, despite all the OIDC setup being done
#resource "helm_release" "aws-load-balancer-controller" {
#  name       = "aws-load-balancer-controller"
#  chart      = "aws-load-balancer-controller"
#  repository = "https://aws.github.io/eks-charts"
#  timeout = "1000"
#  count = 1
#
#  set {
#    name  = "clusterName"
#    value = var.cluster_name
#  }
#
#  set {
#    name  = "serviceAccount.create"
#    value = false
#  }
#
#  set {
#    name  = "serviceAccount.name"
#    value = "aws-load-balancer-controller"
#  }
#
##  set {
##    name  = "vpcId"
##    value = var.vpc_id
##  }
##
##  set {
##    name = "region"
##    value = var.region
##  }
#
#}

resource "helm_release" "guardian-message-broker" {
  name       = "guardian-message-broker"
  chart      = "nats"
  repository = "https://nats-io.github.io/k8s/helm/charts/"
  timeout = "500"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-message-broker/values.yaml")}"
  ]

  set {
    name  = "cluster.enabled"
    value = "false"
  }

  set {
    name  = "cluster.replicas"
    value = "1"
  }


  set {
    name  = "fullnameOverride"
    value = "message-broker"
  }

  depends_on = [helm_release.mongodb]
}

resource "helm_release" "guardian-logger-service" {
  name       = "guardian-logger-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-logger-service"
  repository = "${var.docker_repository}/logger-service"

  timeout = "500"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-logger-service/values.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/logger-service"
  }
  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  depends_on = [helm_release.mongodb, helm_release.guardian-message-broker]

}

resource "helm_release" "guardian-auth-service" {
  name       = "guardian-auth-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-auth-service"
  repository = "${var.docker_repository}/auth-service"

  timeout = "500"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-auth-service/values.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/auth-service"
  }
  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "global.guardian.accessTokenSecret"
    value = var.guardian_access_token_secret
  }

  depends_on = [helm_release.guardian-message-broker]
}

resource "helm_release" "guardian-api-gateway" {
  name       = "guardian-api-gateway"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-api-gateway"
  repository = "${var.docker_repository}/api-gateway"

  timeout = "500"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-api-gateway/values.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/api-gateway"
  }

  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  depends_on = [helm_release.guardian-message-broker]
}

resource "helm_release" "guardian-guardian-service" {
  name       = "guardian-guardian-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-guardian-service"
  repository = "${var.docker_repository}/guardian-service"

  timeout = "500"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-guardian-service/values.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/guardian-service"
  }

  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "global.guardian.operatorId"
    value = coalesce(var.guardian_operator_id, "operatoridfailed")
  }

  set {
    name  = "global.guardian.operatorKey"
    value = coalesce(var.guardian_operator_key, "operatorkeyfailed")
  }

  set {
    name  = "global.guardian.topicId"
    value = coalesce(var.guardian_topic_id, "0.0.0000000")
  }

  set {
    name  = "global.guardian.maxTransactionFee"
    value = coalesce(var.guardian_max_transaction_fee, 0)
  }

  set {
    name  = "global.guardian.initialBalance"
    value = coalesce(var.guardian_initial_balance, 0)
  }

  depends_on = [helm_release.guardian-message-broker]

}

resource "helm_release" "guardian-web-proxy" {
  name       = "guardian-web-proxy"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-web-proxy"
  repository = "${var.docker_repository}/frontend"

  timeout = "500"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-web-proxy/values.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/frontend"
  }

  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "eks.securityGroups"
    value = var.aws_elb_sec_grp
  }

  depends_on = [helm_release.guardian-message-broker]
}

resource "helm_release" "guardian-ipfs-client" {
  name       = "guardian-ipfs-client"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-ipfs-client"
  repository = "${var.docker_repository}/ipfs-client"

  timeout      = "500"
  force_update = true

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-ipfs-client/values.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/ipfs-client"
  }

  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "global.guardian.ipfsKey"
    value = var.guardian_ipfs_key
  }

  depends_on = [helm_release.guardian-message-broker]
}
