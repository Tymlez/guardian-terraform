#!/bin/bash
#
# Builds a Docker image and pushes to an AWS ECR repository
#
# Invoked by the terraform-aws-ecr-docker-image Terraform module.
#
# Usage:
#
# # Acquire an AWS session token
# $ ./push.sh . latest
#

set -e

source_path="$1"
docker_compose_cmd="$2"
docker_hub_username="$3"
docker_hub_password="$4"
docker_repository="$5"

docker login --username "$docker_hub_username" --password "$docker_hub_password"

export DOCKER_REPOSITORY=$docker_hub_repository

cd "$source_path" && "$docker_compose_cmd" build

echo $DOCKER_HUB_REPOSITORY

$docker_compose_cmd push