#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tool versions
check_helm_version

# Bash input variables:
readonly CHART_NAME=${1:-}
readonly NAMESPACE=${2:-}

# Parameter validations:
if [[ -z ${CHART_NAME} ]] || [[ -z ${NAMESPACE} ]] ; then
  echo "usage: ${0} CHART_NAME NAMESPACE"
  exit 1
fi

# Verify if the stack exists abd define update or create task
if helm_chart_exists "${CHART_NAME}" "${NAMESPACE}" > /dev/null 2>&1; then
  print_info "Running helm test"
  helm test --namespace "${NAMESPACE}" "${CHART_NAME}"
else
  print_error "Chart ${CHART_NAME} doesn't exist"
fi

print_success "The task has run successfully"
