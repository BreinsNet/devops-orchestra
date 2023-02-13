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
  exit 1
fi

# Verify if the stack exists abd define update or create task
if cfn_stack_exists "${STACK_NAME}" > /dev/null 2>&1; then
  readonly action='update-stack'
  print_info "Stack ${STACK_NAME} already exist, action is UPDATE"
else
  readonly action='create-stack'
  print_info "Stack ${STACK_NAME} doesn't exist, action is CREATE"
fi

# Build extra params with optional variables
AWS_COMMAND="aws cloudformation $action"
AWS_COMMAND="${AWS_COMMAND} --stack-name ${STACK_NAME}"
AWS_COMMAND="${AWS_COMMAND} --template-body file://${TEMPLATE_FILE}"

if [[ -n ${PARAMETERS} ]]; then
  AWS_COMMAND="${AWS_COMMAND} --parameters ${PARAMETERS}"
fi

if [[ -n ${CAPABILITIES} ]]; then
  AWS_COMMAND="${AWS_COMMAND} --capabilities ${CAPABILITIES}"
fi

# Apply cloudformation template
print_info "Running ${action} on ${STACK_NAME}"
bash -c "${AWS_COMMAND}" > output 2>&1  && \
  retval=$? || retval=$?

output=$(cat output); rm output

# Handle no update required
if [[ ${retval} -ne 0 ]]; then
  if echo "${output}"|grep "No updates are to be performed" > /dev/null; then
    print_info "Template is up to date"
    print_success "The task has run successfully"

    exit 0
  else
    print_warning "The task returned the following message"
    echo -e "${output}\\n"

    cfn_print_resource_status_reasons "${STACK_NAME}" "${output}"
    print_error "The task did not complete successfully"
  fi
fi

cfn_stack_get_status_progress "${STACK_NAME}" "${output}"

print_success "The task has run successfully"
