#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version

# Bash input variables:
readonly TEMPLATE_FILE=${1:-}

# Parameter validations:
if [[ -z ${TEMPLATE_FILE} ]]; then
  echo "usage: ${0} TEMPLATE_FILE"
  exit 1
fi

# Validate template
aws cloudformation validate-template \
  --template-body file://"${TEMPLATE_FILE}" > /dev/null

print_info "Cloudformation template has been validated"

print_success "The task has run successfully"
