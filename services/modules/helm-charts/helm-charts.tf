locals {
  whitelist = join(",", var.whitelisted_ips)
  enable_apm_name = var.enabled_newrelic ? "newrelic": ""
}

resource "helm_release" "mongodb" {
  name       = "mongodb"
  chart      = "mongodb"
  repository = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
  version    = "10.30.0"

  values = [
    "${file("${path.root}/modules/helm-charts/charts/mongodb/values.yaml")}",
    "${file("${path.root}/modules/helm-charts/charts/mongodb/aws-pvc.yaml")}",
    "${file("${path.root}/modules/helm-charts/charts/mongodb/gcp-pvc.yaml")}"
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
  timeout    = "500"

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
    name  = "nats.limits.maxPayload"
    value = "64mb"
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

  timeout = "180"
  # force_update = true
  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-logger-service/values.yaml")}"
  ]

 set {
    name  = "resources.limits.cpu"
    value = var.resource_configs.guardian_logger_service.cpu
  }
  set {
    name  = "resources.limits.memory"
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
    name = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-logger-service/**") : filesha1(f)]))
  }

  depends_on = [helm_release.mongodb, helm_release.guardian-message-broker]

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

  set_sensitive  {
    name  = "global.guardian.accessTokenSecret"
    value = var.guardian_access_token_secret
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
    name = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-auth-service/**") : filesha1(f)]))
  }
  depends_on = [helm_release.guardian-message-broker, helm_release.guardian-logger-service]
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
    name = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-api-gateway/**") : filesha1(f)]))
  }
   
  depends_on = [helm_release.guardian-message-broker]
}

resource "helm_release" "guardian-guardian-service" {
  name       = "guardian-guardian-service"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-guardian-service"
  repository = "${var.docker_repository}/guardian-service"

  timeout = "180"

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
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }

   set {
    name  = "resources.limits.cpu"
    value = var.resource_configs.guardian_guardian_service.cpu
  }
  set {
    name  = "resources.limits.memory"
    value = var.resource_configs.guardian_guardian_service.memory
  }
   set {
    name  = "resources.requests.cpu"
    value = var.resource_configs.guardian_guardian_service.cpu
  }
  set {
    name  = "resources.requests.memory"
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
    name = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-guardian-service/**") : filesha1(f)]))
  }

  depends_on = [helm_release.guardian-message-broker]

}

resource "helm_release" "guardian-web-proxy" {
  name       = "guardian-web-proxy"
  chart      = "${path.root}/modules/helm-charts/charts/guardian-web-proxy"
  repository = "${var.docker_repository}/frontend"

  timeout = "180"

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
#  repository = "${var.docker_repository}/ipfs-client"

  timeout = "180"

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
  set {
    name  = "global.guardian.enable_apm_name"
    value = local.enable_apm_name
  }
  set {
    name  = "resources.limits.cpu"
    value = var.resource_configs.guardian_ipfs_client.cpu
  }
  set {
    name  = "resources.limits.memory"
    value = var.resource_configs.guardian_ipfs_client.memory
  }

  set {
    name  = "resources.requests.cpu"
    value = var.resource_configs.guardian_ipfs_client.cpu
  }
  set {
    name  = "resources.requests.memory"
    value = var.resource_configs.guardian_ipfs_client.memory
  }

  set {
    name  = "replicaCount"
    value = var.resource_configs.guardian_ipfs_client.replicas
  }
  set {
    name  = "autoscaling.enabled"
    value = var.resource_configs.guardian_ipfs_client.autoscale
  }

  set {
    name = "chart-sha1"
    value = sha1(join("", [for f in fileset(path.root, "modules/helm-charts/charts/guardian-ipfs-client/**") : filesha1(f)]))
  }

  depends_on = [helm_release.guardian-message-broker, helm_release.guardian-logger-service]
}

resource "helm_release" "vault" {
  name       = "vault"
  chart      = "vault"
  repository = "https://helm.releases.hashicorp.com"

  depends_on = [helm_release.guardian-message-broker]
}

data "archive_file" "guardian-extensions" {
  type        = "zip"
  source_dir = "${path.root}/modules/helm-charts/charts/guardian-extensions"
  output_path = "/tmp/guardian-extensions.zip"
}

resource "helm_release" "ingress-nginx" {
    name = "ingress-nginx"
    chart = "ingress-nginx"
    version = "4.1.4"
    repository =  "https://kubernetes.github.io/ingress-nginx"
}

resource "helm_release" "guardian-extensions" {
  name  = "guardian-extensions"
  
  chart = "${path.root}/modules/helm-charts/charts/guardian-extensions"

  timeout = "100"
  force_update = true
  values = [
    "${file("${path.root}/modules/helm-charts/charts/guardian-extensions/values.yaml")}"
  ]

  set {
    name  = "global.guardian.whitelistedIps"
    value = "{${local.whitelist}}"
  }
  
  set {
    name  = "global.enable_newrelic"
    value = "${var.enabled_newrelic}"
  }
  set {
    name  = "global.newrelic_license_key"
    value = "${var.newrelic_license_key}"
  }
  
  set {
    name  = "global.apm_labels"
    value = "env:${var.stage}"
  }

  set {
    name = "chart-sha1"
    value = data.archive_file.guardian-extensions.output_sha
  }
}


# resource "helm_release" "extensions" {
#   for_each = toset(var.custom_helm_charts)
#   name     = each.value
#   chart    = each.value
#   repository = var.custom_helm_repository

#   repository_username = var.custom_helm_repository_username
#   repository_password = var.custom_helm_repository_password

#   values = [
#     "${file("${path.root}/custom_values.yaml")}"
#   ]
# #  set {
# #    name  = "global.guardian.whitelistedIps"
# #    value = "{${local.whitelist}}"
# #  }



#   depends_on = [helm_release.guardian-message-broker]
# }