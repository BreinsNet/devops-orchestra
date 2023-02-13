#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_helm_version

# inline input mandatory variables:
readonly CHART_NAME=${1:-}
readonly NAMESPACE=${2:-}

# variables coming from environment variables
readonly VALUES_LIST=${VALUES_LIST:-}
readonly SET_LIST=${SET_LIST:-}
readonly TIMEOUT=${TIMEOUT:-}

# Mandatory parameter validation and help
if [[ -z ${CHART_NAME} ]] || [[ -z ${NAMESPACE} ]] ; then
  echo "usage: ${0} CHART_NAME NAMESPACE"
  echo
  echo Optional environment variables:
  echo "- VALUES_LIST - CSV: pass --values-Value1 --values-Value2 --values-Value3"
  echo "- SET_LIST - CSV: pass --set Key1=Value1 --set Key2=Value2"

  exit 1
fi

# install helm plugin
if ! helm diff --help > /dev/null 2>&1; then
  print_info "Installing helm diff plugin"
  helm plugin install https://github.com/databus23/helm-diff
fi

# Build extra params with optional variables
EXTRA_PARAMS=""
IFS="|"
if [[ -n ${VALUES_LIST} ]]; then
  for value in ${VALUES_LIST}; do
    EXTRA_PARAMS="${EXTRA_PARAMS} --values values-${value}.yaml"
  done
fi

if [[ -n ${SET_LIST} ]]; then
  for set_value in ${SET_LIST}; do
    EXTRA_PARAMS="${EXTRA_PARAMS} --set ${set_value}"
  done
fi

unset IFS

# Do the thing
print_info "Running diff upgrade on ${CHART_NAME}"

# shellcheck disable=SC2086
helm diff upgrade \
  --install \
  --namespace "${NAMESPACE}" \
  --values values.yaml \
  ${EXTRA_PARAMS} \
  "${CHART_NAME}" .

print_success "The task has run successfully"
