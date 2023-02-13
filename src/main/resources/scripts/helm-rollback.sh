#!/bin/bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# inline input mandatory variables:
readonly CHART_NAME=${1:-}
readonly NAMESPACE=${2:-}
readonly SET_DEBUG=${SET_DEBUG:-}

# Mandatory parameter validation and help
if [[ -z ${CHART_NAME} ]] || [[ -z ${NAMESPACE} ]] ; then
  echo "usage: ${0} CHART_NAME NAMESPACE"
  echo

  exit 1
fi

# Build extra params with optional variables
EXTRA_PARAMS=""

if [[ ${SET_DEBUG} = 'true' ]]; then
  EXTRA_PARAMS="${EXTRA_PARAMS} --debug"
fi

# Do the thing
print_info "Running rollback on ${CHART_NAME}"

helm rollback \
  --namespace "${NAMESPACE}" \
  "${EXTRA_PARAMS}" \
  "${CHART_NAME}" .

print_success "The task has run successfully"
