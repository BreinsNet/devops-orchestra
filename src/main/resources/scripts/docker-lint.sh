#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly REPOSITORY_NAME=501584834092.dkr.ecr.eu-west-1.amazonaws.com/ecom-su-ecr-repository/hadolint:v2.8.0-alpine

docker run --rm --interactive ${REPOSITORY_NAME} hadolint -V - < Dockerfile

print_success "The task has run successfully"
