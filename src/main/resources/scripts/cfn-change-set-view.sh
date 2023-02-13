#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version
check_jq_version

# Bash input variables:
readonly TEMPLATE_FILE=${1:-}
readonly STACK_NAME=${2:-}

# Parameter validations:
if [[ -z ${STACK_NAME} ]] || [[ -z ${TEMPLATE_FILE} ]]; then
  echo "usage: ${0} TEMPLATE_FILE STACK_NAME"
  exit 1
fi

# Verify if the stack exists abd define update or create task
if ! cfn_stack_exists "${STACK_NAME}" > /dev/null 2>&1; then
  print_warning "Stack ${STACK_NAME} doesn't exist, can't continue"
  exit 0
fi

# Generate unique identifier
export MD5_SUM
export CHANGE_SET_ARN

MD5_SUM=$(md5sum "${TEMPLATE_FILE}"|cut -b -5)

readonly CHANGE_SET_NAME=${STACK_NAME}-${MD5_SUM}

CHANGE_SET_ARN=$(aws cloudformation list-change-sets \
  --stack-name "${STACK_NAME}"| \
  jq -r ".Summaries[]|select(.ChangeSetName = \"${CHANGE_SET_NAME}\")|.ChangeSetId")

if [[ -z ${CHANGE_SET_ARN} ]]; then
  print_warning "No changeset available for ${STACK_NAME} with md5sum ${MD5_SUM}"
  exit 0
fi

# Build aws command
AWS_COMMAND="aws cloudformation describe-change-set --change-set-name ${CHANGE_SET_ARN}|jq -r .Changes[]"

# create a changeset
print_info "Listing changes to be applied for ${STACK_NAME} with md5sum ${MD5_SUM}"
bash -c "${AWS_COMMAND}"

print_success "The task has run successfully"
