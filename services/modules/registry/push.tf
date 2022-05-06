# Calculate hash of the Docker image source contents
data "external" "hash" {
  program = ["${path.module}/hash.sh", "${var.source_path}/docker-compose.yml"]
}

# Build and push the Docker image whenever the hash changes
resource "null_resource" "push" {
  triggers = {
   hash = data.external.hash.result["hash"]
  }

  provisioner "local-exec" {
    command     = "${coalesce(var.push_script, "${path.module}/push.sh")} '${var.source_path}' ${var.docker_compose_cmd} ${var.docker_hub_username} '${var.docker_hub_password}' '${var.docker_hub_repository}'"
    interpreter = ["bash", "-c"]
  }
}
