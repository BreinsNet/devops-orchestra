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

if [[ -n ${TIMEOUT} ]]; then
  EXTRA_PARAMS="${EXTRA_PARAMS} --timeout ${TIMEOUT}"
fi

unset IFS

# Collect the chart status
declare CHART_STATUS

CHART_STATUS=$(helm_chart_status "${CHART_NAME}" "${NAMESPACE}")

# If the helm chart is in "pending-update" state, first rollback to the latest "deployed" release
if [[ ${CHART_STATUS} =~ pending-upgrade|pending-rollback ]]; then
  print_warning "The helm chart ${CHART_NAME} is in pending-upgrade status, rolling back to last stable release first"

  if ! helm_latest_release "${CHART_NAME}" "${NAMESPACE}"; then
    print_warning "There is no helm chart release that match /deployed|superseded.*complete/ criteria to rollback"
    print_error "Consider run ./gradlew :helmUninstall or manual doing helm uninstall -n ${NAMESPACE} ${CHART_NAME} and run this again"
  fi

  LATEST_DEPLOYED_RELEASE=$(helm_latest_release "${CHART_NAME}" "${NAMESPACE}")

  print_info "Rolling back ${CHART_NAME} to release ${LATEST_DEPLOYED_RELEASE}"
  helm rollback \
    --namespace "${NAMESPACE}" \
    --wait \
    --wait-for-jobs \
    "${CHART_NAME}" "${LATEST_DEPLOYED_RELEASE}"
fi

# If the helm chart is in "pending-install" state, first uninstall
if [[ ${CHART_STATUS} = pending-install ]]; then
  print_warning "The helm chart ${CHART_NAME} is in pending-install status, uninstalling chart first"

  helm uninstall \
    --wait \
    --namespace "${NAMESPACE}" \
    "${CHART_NAME}"
fi

# Do the thing
print_info "Running upgrade/install on ${CHART_NAME}"

# shellcheck disable=SC2086
helm upgrade \
  --install \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --wait \
  --wait-for-jobs \
  --values values.yaml \
  ${EXTRA_PARAMS} \
  "${CHART_NAME}" .

print_success "The task has run successfully"
