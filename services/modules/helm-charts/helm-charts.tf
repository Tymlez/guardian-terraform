resource "helm_release" "mongodb" {
  name              = "mongodb"
  chart             = "mongodb"
  repository        = "https://charts.bitnami.com/bitnami"
  version           = "10.30.0"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/mongodb/values.yaml")}",
    "${file("${path.root}/modules/helm-charts/charts/mongodb/aws-pvc.yaml")}", #required for EKS Bullshit, shouldnt affect other clouds
  ]

  set {
      name  = "auth.enabled"
      value = "false"
  }


}

resource "helm_release" "guardian-message-broker" {
  name       = "guardian-message-broker"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-message-broker"
  repository = "registry-1.docker.io/${var.docker_hub_repository}/guardian-message-broker"
  
  timeout    = "120"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-message-broker/values.yaml")}"
  ]


  set {
      name  = "image.repository"
      value = "registry-1.docker.io/${var.docker_hub_repository}/guardian-message-broker"
  }

  set {
      name  = "image.tag"
      value = "latest"
  }
  depends_on = [helm_release.mongodb]
}

resource "helm_release" "guardian-logger-service" {
  name       = "guardian-logger-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-logger-service"
  repository = "registry-1.docker.io/${var.docker_hub_repository}/guardian-logger-service"
  
  timeout    = "120"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-logger-service/values.yaml")}"
  ]

  set {
      name  = "image.repository"
      value = "registry-1.docker.io/${var.docker_hub_repository}/guardian-logger-service"
  }
  set {
      name  = "image.tag"
      value = "latest"
  }

  depends_on = [helm_release.mongodb, helm_release.guardian-message-broker]

}

resource "helm_release" "guardian-auth-service" {
  name       = "guardian-auth-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-auth-service"
  repository = "registry-1.docker.io/${var.docker_hub_repository}/guardian-auth-service"
  
  timeout    = "120"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-auth-service/values.yaml")}"
  ]

  set {
      name  = "image.repository"
      value = "registry-1.docker.io/${var.docker_hub_repository}/guardian-auth-service"
  }
  set {
      name  = "image.tag"
      value = "latest"
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
  repository = "registry-1.docker.io/${var.docker_hub_repository}/guardian-api-gateway"
  
  timeout    = "120"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-api-gateway/values.yaml")}"
  ]

  set {
      name  = "image.repository"
      value = "registry-1.docker.io/${var.docker_hub_repository}/guardian-api-gateway"
  }

  set {
      name  = "image.tag"
      value = "latest"
  }

  depends_on = [helm_release.guardian-message-broker]
}

resource "helm_release" "guardian-guardian-service" {
  name       = "guardian-guardian-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-guardian-service"
  repository = "registry-1.docker.io/${var.docker_hub_repository}/guardian-guardian-service"
  
  timeout    = "120"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-guardian-service/values.yaml")}"
  ]

  set {
      name  = "image.repository"
      value = "registry-1.docker.io/${var.docker_hub_repository}/guardian-guardian-service"
  }

  set {
      name  = "image.tag"
      value = "latest"
  }

  set {
      name  = "global.guardian.operatorId"
      value = var.guardian_operator_id
  }

  set {
      name  = "global.guardian.operatorKey"
      value = var.guardian_operator_key
  }

  set {
      name  = "global.guardian.topicId"
      value = var.guardian_topic_id
  }

  depends_on = [helm_release.guardian-message-broker]

}

resource "helm_release" "guardian-web-proxy" {
  name       = "guardian-web-proxy"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-web-proxy"
  repository = "registry-1.docker.io/${var.docker_hub_repository}/guardian-web-proxy"
  
  timeout    = "120"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-web-proxy/values.yaml")}"
  ]

  set {
      name  = "image.repository"
      value = "registry-1.docker.io/${var.docker_hub_repository}/guardian-web-proxy"
  }

  set {
      name  = "image.tag"
      value = "latest"
  }

  depends_on = [helm_release.guardian-message-broker]
}

resource "helm_release" "guardian-ipfs-client" {
  name       = "guardian-ipfs-client"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-ipfs-client"
  repository = "registry-1.docker.io/${var.docker_hub_repository}/guardian-ipfs-client"
  
  timeout    = "300"
  force_update = true

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-ipfs-client/values.yaml")}"
  ]

  set {
      name  = "image.repository"
      value = "registry-1.docker.io/${var.docker_hub_repository}/guardian-ipfs-client"
  }

  set {
      name  = "image.tag"
      value = "latest"
  }

  set {
      name  = "global.guardian.ipfsKey"
      value = var.guardian_ipfs_key
  }

  depends_on = [helm_release.guardian-message-broker]
}