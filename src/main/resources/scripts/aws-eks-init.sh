#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version

# Bash input variables:
readonly CLUSTER_NAME=${1:-}

# Parameter validations:
if [[ -z ${CLUSTER_NAME} ]] ; then
  echo "usage: ${0} CLUSTER_NAME"
  exit 1
fi

print_info "Initializing ${CLUSTER_NAME}"
aws eks update-kubeconfig --name "${CLUSTER_NAME}"

print_success "The task has run successfully"
