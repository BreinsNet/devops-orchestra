#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version

# Bash input variables:
readonly ZIP_FILE=${1:-}
readonly BUCKET_NAME=${2:-}

# Parameter validations:
if [[ -z ${ZIP_FILE} ]] || [[ -z ${BUCKET_NAME} ]]; then
  echo "usage: ${0} ZIP_FILE BUCKET_NAME"
  exit 1
fi

if [[ ! -f ${ZIP_FILE} ]]; then
  print_error "${PWD}/${ZIP_FILE} does not exist"
fi

# Do the thing
print_info "Uploading ${ZIP_FILE} to s3://${BUCKET_NAME}/${ZIP_FILE}"
aws s3 cp "${ZIP_FILE}" "s3://${BUCKET_NAME}/${ZIP_FILE}"

print_success "The task has run successfully"
