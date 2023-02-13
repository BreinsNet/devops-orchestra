#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version

# Bash input variables:
readonly STACK_NAME=${1:-}

# Parameter validations:
if [[ -z ${STACK_NAME} ]] ; then
  echo "usage: ${0}  STACK_NAME"
  exit 1
fi

# Apply cloudformation template
print_info "Running delete-stack on ${STACK_NAME}"
echo y | sam delete --stack-name "${STACK_NAME}"| \
  grep -v 'Are you sure you want to delete'

print_success "The task has run successfully"
