locals {
  ingress_whitelisted_ips = tostring(format("%s", join("\\,", var.ingress_whitelisted_ips)))
  enable_apm_name         = var.enabled_newrelic ? "newrelic" : ""
}

resource "helm_release" "vault" {
  count        = var.vault_config.self_host ? 1 : 0
  name         = "vault"
  chart        = "vault"
  repository   = "https://helm.releases.hashicorp.com"
  reuse_values = true
  values = [

  ]
}

resource "helm_release" "mongodb" {
  name         = "mongodb"
  chart        = "mongodb"
  repository   = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
  version      = "10.30.0"
  reuse_values = true


  values = [
    "${file("${path.root}/modules/helm-charts/charts/mongodb/values.yaml")}",
    "${file("${path.root}/modules/helm-charts/charts/mongodb/aws-pvc.yaml")}",
    "${file("${path.root}/modules/helm-charts/charts/mongodb/gcp-pvc.yaml")}"
  ]

  set {
    name  = "auth.enabled"
    value = "false"
  }
  set {
    name  = "persistence.size"
    value = var.guardian_mongodb_persistent_size
  }

  #force mongo to be on the same AWS Zone (not needed for GCP) 💩
  set {
    name  = "controller.nodeSelector"
    value = "topology.kubernetes.io/zone=${var.aws_zone}"
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
  timeout    = "500"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-message-broker/values.yaml")}"
  ]

  set {
    name  = "cluster.enabled"
    value = var.resource_configs.nats.autoscale
  }

  set {
    name  = "cluster.replicas"
    value = var.resource_configs.nats.replicas
  }

  set {
    name  = "nats.limits.maxPayload"
    value = "64mb"
  }

  set {
    name  = "nats.resources.requests.cpu"
    value = var.resource_configs.nats.cpu
  }

  set {
    name  = "nats.resources.requests.memory"
    value = var.resource_configs.nats.memory
  }

  set {
    name  = "fullnameOverride"
    value = "message-broker"
  }

  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-message-broker/**") : filesha1(f)]))
  }
}

resource "helm_release" "guardian-logger-service" {
  name       = "guardian-logger-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-logger-service"
  repository = "${var.docker_repository}/logger-service"

  timeout = "180"
  # force_update = true
  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-logger-service/values.yaml")}"
  ]



  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_logger_service.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_logger_service.memory
  }
  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_logger_service.replicas
  }
  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_logger_service.autoscale
  }

  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }
  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/logger-service"
  }

  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-logger-service/**") : filesha1(f)]))
  }

  depends_on = [helm_release.mongodb, helm_release.extensions, helm_release.guardian-message-broker]

}

resource "helm_release" "guardian-auth-service" {
  name       = "guardian-auth-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-auth-service"
  repository = "${var.docker_repository}/auth-service"

  timeout = "180"

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

  set_sensitive {
    name  = "global.guardian.accessTokenSecret"
    value = var.guardian_access_token_secret
  }

  set_sensitive {
    name  = "global.vault.vault_token"
    value = var.vault_token
  }

  set {
    name  = "global.vault.vault_provider"
    value = var.vault_config.vault_provider
  }

  set {
    name  = "global.vault.vault_url"
    value = var.vault_config.vault_url
  }

  set {
    name  = "global.vault.vault_workspace"
    value = var.vault_config.vault_workspace
  }
  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }

  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_auth_service.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_auth_service.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_auth_service.replicas
  }
  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_auth_service.autoscale
  }

  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-auth-service/**") : filesha1(f)]))
  }
  depends_on = [helm_release.guardian-message-broker, helm_release.extensions, helm_release.guardian-logger-service]
}

resource "helm_release" "guardian-api-gateway" {
  name       = "guardian-api-gateway"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-api-gateway"
  repository = "${var.docker_repository}/api-gateway"

  timeout = "180"

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

  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }

  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_api_gateway.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_api_gateway.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_api_gateway.replicas
  }
  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_api_gateway.autoscale
  }

  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-api-gateway/**") : filesha1(f)]))
  }

  depends_on = [helm_release.guardian-message-broker, helm_release.extensions, helm_release.guardian-auth-service]
}

resource "helm_release" "guardian-guardian-service" {
  name       = "guardian-guardian-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-guardian-service"
  repository = "${var.docker_repository}/guardian-service"
  timeout    = "360"

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

  set_sensitive {
    name  = "global.guardian.operatorKey"
    value = coalesce(var.guardian_operator_key, "operatorkeyfailed")
  }

  set {
    name  = "global.guardian.initializationTopicId"
    value = coalesce(var.guardian_topic_id, "0.0.0000000")
  }

  set {
    name  = "global.guardian.network"
    value = coalesce(var.guardian_network, "testnet")
  }

  set {
    name  = "global.guardian.logLevel"
    value = coalesce(var.guardian_logger_level, "2")
  }

  set {
    name  = "global.guardian.maxTransactionFee"
    value = coalesce(var.guardian_max_transaction_fee, 20)
  }


  set {
    name  = "global.guardian.initialBalance"
    value = coalesce(var.guardian_initial_balance, 100)
  }
  set {
    name  = "global.guardian.initialStandardRegistryBalance"
    value = coalesce(var.guardian_initial_standard_registry_balance, 100)
  }

  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }

  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_guardian_service.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_guardian_service.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_guardian_service.replicas
  }
  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_guardian_service.autoscale
  }
  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-guardian-service/**") : filesha1(f)]))
  }

  depends_on = [helm_release.guardian-message-broker, helm_release.extensions, helm_release.guardian-auth-service, helm_release.guardian-policy-service]

}

resource "helm_release" "guardian-policy-service" {
  name       = "guardian-policy-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-policy-service"
  repository = "${var.docker_repository}/policy-service"

  timeout = "360"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-policy-service/values.yaml")}"
  ]

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/policy-service"
  }

  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "global.guardian.network"
    value = coalesce(var.guardian_network, "testnet")
  }

  set {
    name  = "global.guardian.logLevel"
    value = coalesce(var.guardian_logger_level, "2")
  }

  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }

  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_policy_service.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_policy_service.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_policy_service.replicas
  }
  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_policy_service.autoscale
  }
  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-policy-service/**") : filesha1(f)]))
  }

  depends_on = [helm_release.guardian-message-broker, helm_release.extensions, helm_release.guardian-auth-service]

}

resource "helm_release" "guardian-frontend" {
  name       = "guardian-frontend"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-frontend"
  repository = "${var.docker_repository}/frontend"

  timeout = "180"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-frontend/values.yaml")}"
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

  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_frontend.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_frontend.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_frontend.replicas
  }
  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_frontend.autoscale
  }

  set {
    name  = "service.type"
    value = var.use_ingress ? "ClusterIP" : "LoadBalancer"
  }

  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-frontend/**") : filesha1(f)]))
  }


  depends_on = [helm_release.guardian-api-gateway, helm_release.extensions]
}

resource "helm_release" "guardian-worker-service" {
  name  = "guardian-worker-service"
  chart = "${path.root}/modules/helm-charts/charts/guardian-worker-service"
  #  repository = "${var.docker_repository}/ipfs-client"

  timeout = "180"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-worker-service/values.yaml")}"
  ]

  set_sensitive {
    name  = "global.guardian.ipfsKey"
    value = var.guardian_ipfs_key
  }
  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-worker-service/**") : filesha1(f)]))
  }

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/worker-service"
  }

  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }

  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_worker_service.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_worker_service.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_worker_service.replicas
  }

  set {
    name  = "autoscaling.minReplicas"
    value = var.resource_configs.guardian_worker_service.replicas
  }

  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_worker_service.autoscale
  }

  depends_on = [helm_release.guardian-message-broker, helm_release.extensions, helm_release.guardian-auth-service]
}

resource "helm_release" "guardian-application-events" {
  name         = "guardian-application-events"
  chart        = "${path.root}/modules/helm-charts/charts/guardian-application-events"
  force_update = true
  timeout      = "180"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-application-events/values.yaml")}"
  ]


  set {
    name  = "chart-sha"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-application-events/**") : filesha1(f)]))
  }

  set {
    name  = "image.repository"
    value = "${var.docker_repository}/application-events"
  }

  set {
    name  = "image.tag"
    value = var.guardian_version
  }

  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }

  set {
    name  = "resources.cpu"
    value = var.resource_configs.guardian_application_events.cpu
  }
  set {
    name  = "resources.memory"
    value = var.resource_configs.guardian_application_events.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_application_events.replicas
  }

  set {
    name  = "autoscaling.minReplicas"
    value = var.resource_configs.guardian_application_events.replicas
  }

  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_application_events.autoscale
  }

  depends_on = [helm_release.guardian-message-broker, helm_release.extensions]
}


resource "helm_release" "ingress-nginx" {
  count      = var.use_ingress ? 1 : 0
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.2.1"
  repository = "https://kubernetes.github.io/ingress-nginx"
  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  # set {
  #   name  = "controller.config.use-proxy-protocol"
  #   value = "true"
  # }
}

resource "helm_release" "guardian-extensions" {
  name = "guardian-extensions"

  chart = "${path.root}/modules/helm-charts/charts/guardian-extensions"

  timeout      = "100"
  force_update = true
  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-extensions/values.yaml")}",

  ]

  set {
    name  = "global.guardian.network"
    value = coalesce(var.guardian_network, "testnet")
  }

  set {
    name  = "vault_keys"
    value = var.vault_keys
  }

  set {
    name  = "ingress.whitelistedIps"
    value = local.ingress_whitelisted_ips
  }

  set {
    name  = "ingress.custom_helm_ingresses.enable"
    value = var.custom_helm_ingresses.enable
  }


  set {
    name  = "ingress.custom_helm_ingresses.service_name"
    value = var.custom_helm_ingresses.service_name
  }


  set {
    name  = "ingress.custom_helm_ingresses.service_path"
    value = var.custom_helm_ingresses.service_path
  }

  set {
    name  = "ingress.custom_helm_ingresses.service_port"
    value = var.custom_helm_ingresses.service_port
  }
  set {
    name  = "global.enable_newrelic"
    value = var.enabled_newrelic
  }

  set {
    name  = "global.newrelic_license_key"
    value = var.newrelic_license_key
  }

  set {
    name  = "global.apm_labels"
    value = "env:${var.stage}"
  }

  set {
    name  = "global.guardian.mq_message_chunk"
    value = var.mq_message_size
  }

  set {
    name  = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-extensions/**") : filesha1(f)]))
  }

  depends_on = [helm_release.guardian-message-broker, helm_release.extensions]

}

resource "helm_release" "extensions" {
  for_each = {
    for charts in var.custom_helm_charts : charts => charts
    if length(var.custom_helm_charts) > 0
  }

  name       = each.value
  chart      = each.value
  repository = var.custom_helm_repository

  repository_username = var.custom_helm_repository_username
  repository_password = var.custom_helm_repository_password

  values = [
    try(yamlencode(var.custom_helm_values_yaml[each.value]), "{}")
  ]

  depends_on = [helm_release.guardian-message-broker]
}
