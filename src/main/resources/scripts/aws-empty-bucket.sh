#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version

# Bash input variables:
readonly BUCKET_NAME=${1:-}

# Parameter validations:
if [[ -z ${BUCKET_NAME} ]] ; then
  echo "usage: ${0} BUCKET_NAME"
  exit 1
fi

# Do the thing:
print_info "Deleting all objects on ${BUCKET_NAME} including versions"
aws s3api delete-objects \
  --bucket "${BUCKET_NAME}" \
  --delete "$(aws s3api list-object-versions \
  --output=json \
  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

print_success "The task has run successfully"
