#!/bin/bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_aws_version

readonly SSM_SECRET_KEY=${1:-}
readonly FILE_NAME=${2:-}

# Mandatory parameter validation and help
if [[ -z ${SSM_SECRET_KEY} ]] || [[ -z ${FILE_NAME} ]] ; then
  echo "usage: ${0} SSM_SECRET_KEY FILE_NAME"
  echo

  exit 1
fi

# Do the thing
aws ssm get-parameters --name "$SSM_SECRET_KEY" \
  --with-decryption \
  --output text \
  --query Parameters[].Value > output.json

cfn-flip output.json "${FILE_NAME}"

rm output.json

print_success "The task has run successfully"
