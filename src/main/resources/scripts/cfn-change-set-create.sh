#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version

# Bash input variables:
readonly TEMPLATE_FILE=${1:-}
readonly STACK_NAME=${2:-}

# variables coming from environment variables
readonly PARAMETERS=${PARAMETERS:-}
readonly CAPABILITIES=${CAPABILITIES:-}

# Parameter validations:
if [[ -z ${STACK_NAME} ]] || [[ -z ${TEMPLATE_FILE} ]]; then
  echo "usage: ${0} TEMPLATE_FILE STACK_NAME"
  echo
  echo Optional environment variables:
  echo "- PARAMETERS: Cloudformation --parameters argument"
  echo "- CAPABILITIES: Cloudformation --capabilities argument"
  exit 1
fi

# Verify if the stack exists abd define update or create task
if ! cfn_stack_exists "${STACK_NAME}" > /dev/null 2>&1; then
  print_warning "Stack ${STACK_NAME} doesn't exist, can't continue"
  exit 0
fi

# Generate unique identifier
export MD5_SUM

MD5_SUM=$(md5sum "${TEMPLATE_FILE}"|cut -b -5)
CHANGE_SET_NAME=${STACK_NAME}-${MD5_SUM}

# Build extra params with optional variables
AWS_COMMAND="aws cloudformation create-change-set"
AWS_COMMAND="${AWS_COMMAND} --stack-name ${STACK_NAME}"
AWS_COMMAND="${AWS_COMMAND} --template-body file://${TEMPLATE_FILE}"
AWS_COMMAND="${AWS_COMMAND} --change-set-name ${CHANGE_SET_NAME}"

if [[ -n ${PARAMETERS} ]]; then
  AWS_COMMAND="${AWS_COMMAND} --parameters ${PARAMETERS}"
fi

if [[ -n ${CAPABILITIES} ]]; then
  AWS_COMMAND="${AWS_COMMAND} --capabilities ${CAPABILITIES}"
fi

# create a changeset
print_info "Creating change set ${STACK_NAME} with md5sum ${MD5_SUM}"
bash -c "${AWS_COMMAND}" > /dev/null

# Wait for changeset to be completed
cfn_change_set_get_status_progress "${CHANGE_SET_NAME}" "${STACK_NAME}"

print_success "The task has run successfully"
