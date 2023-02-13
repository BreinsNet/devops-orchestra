#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly IMAGE_NAME_AND_TAG=${1:-}

# Parameter validations:
if [[ -z ${IMAGE_NAME_AND_TAG} ]]; then
  echo "usage: ${0} IMAGE_NAME_AND_TAG"
  exit 1
fi

export DOCKER_CLI_EXPERIMENTAL=enabled

if docker manifest inspect "${IMAGE_NAME_AND_TAG}" > /dev/null 2>&1; then
  print_warning "The image ${IMAGE_NAME_AND_TAG} already exists, not pushing"
else
  docker push "${IMAGE_NAME_AND_TAG}"

  print_success "The task has run successfully"
fi
