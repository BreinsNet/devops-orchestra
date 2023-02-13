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

# Apply cloudformation template
print_info "Running uninstall on ${CHART_NAME}"

helm uninstall \
  --wait \
  --namespace "${NAMESPACE}" \
  "${CHART_NAME}"

print_success "The task has run successfully"
