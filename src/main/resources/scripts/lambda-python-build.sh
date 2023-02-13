#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly SOURCE_PATH=${1:-}
readonly ZIP_FILE=${2:-}

# Parameter validations:
if [[ -z ${SOURCE_PATH} ]] || [[ -z ${ZIP_FILE} ]]; then
  echo "usage: ${0} SOURCE_PATH ZIP_FILE"
  exit 1
fi

if [[ ! -d ${SOURCE_PATH} ]]; then
  print_error "${PWD}/${SOURCE_PATH} does not exist"
fi

if [[ ! -f ${SOURCE_PATH}/requirements.txt ]]; then
  print_error "${PWD}/${SOURCE_PATH}/requirements.txt does not exist"
fi

# do the thing
cd "${SOURCE_PATH}" || exit

print_info "Installing packages from requirements.txt"
pip install --requirement requirements.txt -t .

print_info "Building zip file"
zip --exclude '*__pycache__*' --recurse-paths "../${ZIP_FILE}" ./*

print_success "The task has run successfully"
