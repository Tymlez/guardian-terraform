data "github_release" "guardian" {
    repository  = "guardian"
    owner       = "hashgraph"
    retrieve_by = var.guardian_version != "" ? "tag" : "latest"
    release_tag = var.guardian_version != "" ? var.guardian_version : ""
}

#locals {
#    gh_dl_path = "${path.module}/guardian.zip"
#    gh_file = data.github_release.guardian.zipball_url
#}
#
##resource null_resource gh_forwarder {
##  provisioner local-exec {
##    command = "wget $dl_url -O $dl_path && unzip -j $dl_path"
##
##    environment = {
##      dl_url = local.gh_file
##      dl_path = local.gh_dl_path
##    }
##  }
##  triggers = {
##    always_run = "${timestamp()}"
##  }
##}
data "external" "version" {
  program = ["bash", "${path.root}/modules/guardian/getVersion.sh", "${path.root}/modules/guardian/repo"]
}

resource null_resource gh_clone {

  triggers = {
    clone = data.external.version.result["result"]
  }

  provisioner local-exec {
    command = "rm -rf ${path.root}/modules/guardian/repo && git clone git@github.com:hashgraph/guardian.git --branch ${var.guardian_version != "" ? var.guardian_version : "main"} ${path.root}/modules/guardian/repo"
  }

}