#!/bin/bash
#
# Calculates hash of Docker image source contents
#
# Invoked by the terraform-aws-ecr-docker-image Terraform module.
#
# Usage:
#
# $ ./hash.sh .
#

set -e

source_path="$1"

hash="$(cat $source_path | md5sum | cut -d' ' -f1)"

echo '{ "hash": "'"$hash"'" }'