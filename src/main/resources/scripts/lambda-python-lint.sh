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

if [[ ! -f ${SOURCE_PATH}/requirements.txt ]]; then
  print_error "${PWD}/${SOURCE_PATH}/requirements.txt does not exist"
fi

# do the thing
print_info "Validate python code is valid"
find "${SOURCE_PATH}" -type f -name '*py'|while read -r file; do
  python -m py_compile "${file}"
done

print_info "Validate pinned versions"
if [[ $(grep -cv '==' "${SOURCE_PATH}/requirements.txt") -gt 0 ]]; then
  print_error "Some packages haven't been pinned in the requirements.txt"
fi

print_success "The task has run successfully"
