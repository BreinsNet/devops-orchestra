#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly SOURCE_PATH=${1:-}

# Parameter validations:
if [[ -z ${SOURCE_PATH} ]]; then
  echo "usage: ${0} SOURCE_PATH"
  exit 1
fi

if [[ ! -d ${SOURCE_PATH} ]]; then
  print_error "${PWD}/${SOURCE_PATH} does not exist"
fi

if [[ ! -f ${SOURCE_PATH}/package.json ]]; then
  print_error "${PWD}/${SOURCE_PATH}/package.json does not exist"
fi

if [[ ! -f ${SOURCE_PATH}/package-lock.json ]]; then
  print_error "${PWD}/${SOURCE_PATH}/package-lock.json does not exist"
fi

# do the thing
print_info "Validate node code is valid"
find "${SOURCE_PATH}" -type f -name '*js'|while read -r file; do
  node --check "${file}"
done

print_success "The task has run successfully"
