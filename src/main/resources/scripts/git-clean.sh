#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

readonly GIT_CLEAN_PATH=${1:-}

# Parameter validations:
if [[ -z ${GIT_CLEAN_PATH} ]]; then
  echo "usage: ${0} GIT_CLEAN_PATH"
  exit 1
fi

print_info "Running git clean -fd on ${GIT_CLEAN_PATH}"
cd "${GIT_CLEAN_PATH}" && git clean -fd

print_success "The task has run successfully"
