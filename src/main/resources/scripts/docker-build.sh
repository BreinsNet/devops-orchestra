#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly TAG=${1:-}

# Parameter validations:
if [[ -z ${TAG} ]]; then
  echo "usage: ${0} TAG"
  exit 1
fi

docker build . --tag="${TAG}"

print_success "The task has run successfully"
