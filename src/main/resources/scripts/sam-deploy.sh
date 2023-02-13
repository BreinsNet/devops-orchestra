#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_sam_version

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
  exit 1
fi

# Build extra params with optional variables
SAM_COMMAND="sam deploy --no-fail-on-empty-changeset"
SAM_COMMAND="${SAM_COMMAND} --stack-name ${STACK_NAME}"
SAM_COMMAND="${SAM_COMMAND} --template-file ${TEMPLATE_FILE}"

if [[ -n ${PARAMETERS} ]]; then
  SAM_COMMAND="${SAM_COMMAND} --parameter-overrides ${PARAMETERS}"
fi

if [[ -n ${CAPABILITIES} ]]; then
  SAM_COMMAND="${SAM_COMMAND} --capabilities ${CAPABILITIES}"
fi

# Apply cloudformation template
print_info "Running sam deploy on ${STACK_NAME}"
bash -c "${SAM_COMMAND}"

print_success "The task has run successfully"
