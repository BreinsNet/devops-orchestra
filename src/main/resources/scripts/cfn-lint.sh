#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly TEMPLATE_FILE=${1:-}
readonly REPOSITORY_NAME=501584834092.dkr.ecr.eu-west-1.amazonaws.com/ecom-su-ecr-repository/cfn-nag:0.8.9

# Parameter validations:
if [[ -z ${TEMPLATE_FILE} ]]; then
  echo "usage: ${0} TEMPLATE_FILE"
  exit 1
fi

docker run --rm --interactive ${REPOSITORY_NAME} - < "${TEMPLATE_FILE}"

print_success "The task has run successfully"
