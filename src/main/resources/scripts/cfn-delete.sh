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

# Verify if the stack exists and define delete task
if cfn_stack_exists "${STACK_NAME}" > /dev/null 2>&1; then
  print_info "Stack ${STACK_NAME} exist, action is DELETE"
else
  print_info "Stack ${STACK_NAME} does not exists" #handle the error when stack does not exists
  exit 0
fi

# Apply cloudformation template
print_info "Running delete-stack on ${STACK_NAME}"
aws cloudformation delete-stack --stack-name "${STACK_NAME}"

if cfn_stack_delete_complete "${STACK_NAME}"; then
  print_success "The task has run successfully"
else
  cfn_print_resource_status_reasons "${STACK_NAME}"
  print_error "${STACK_NAME} stack deletion failed!"
fi
