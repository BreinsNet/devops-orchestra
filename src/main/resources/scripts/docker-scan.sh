#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly IMAGE_NAME_AND_TAG=${1:-}
readonly TIMEOUT=60

# Parameter validations:
if [[ -z ${IMAGE_NAME_AND_TAG} ]]; then
  echo "usage: ${0} IMAGE_NAME_AND_TAG"
  exit 1
fi

print_info "Waiting ${TIMEOUT} seconds for Clair to be available on localhost:6060"

timeout ${TIMEOUT} bash -c 'until cat < /dev/null > /dev/tcp/127.0.0.1/6060; do sleep 1; done' > /dev/null 2>&1

print_info "Running docker scan on ${IMAGE_NAME_AND_TAG}"

export DOCKER_USER=AWS
export CLAIR_ADDR=http://localhost:6060
export CLAIR_OUTPUT=High
export CLAIR_WHITELIST_FILE=/tmp/klar/whitelist.yaml
export DOCKER_LOGIN
export DOCKER_PASSWORD
export DOCKER_REGISTRY

DOCKER_LOGIN=$(aws ecr get-login)
DOCKER_PASSWORD=$(echo "${DOCKER_LOGIN}" | cut -d' ' -f6)
DOCKER_REGISTRY=$(echo "${DOCKER_LOGIN}" | cut -d' ' -f9 | sed "s~https://~~")

klar "${IMAGE_NAME_AND_TAG}"

print_success "The task has run successfully"
