#!/bin/bash

# Fix .kube/config permissions. ${HOME} and ${>User} don't exist within gradle tasks
USER=$(id -u)
HOME=$(getent passwd "${USER}" | cut -d: -f6)
KUBECONFIG="${KUBECONFIG:-${HOME}/.kube/config}"

if [[ -f "${KUBECONFIG}" ]] && [[ $(stat "${KUBECONFIG}" --format=%a) != 600 ]]; then
  chmod 600 "${KUBECONFIG}"
fi

# Bash script safe flags
[[ -n ${DEBUG} ]] && set -o xtrace

set -o pipefail
set -o nounset
set -o errexit

# Handle exit on error
handle_error() {
  local timestamp
  local lineno
  local tempfile
  local basename_script
  local script_path
  
  tempfile=$(mktemp)
  lineno=$(caller|awk '{print $1}')
  timestamp=$(date +%s)
  basename_script=$(basename "${0}")
  script_path=$(find . -name "${basename_script}")

  # export all shell variables
  for var in $(set -o posix;set|grep -Po '^[A-Z_]+='|sed s/=//g); do
    export "${var?}"
  done

  # store the output message in a temporary file
  awk 'NR>L-5 && NR<L+10 { printf "%-5d%3s%s\n",NR,(NR==L?">> ":""),$0 }' L="${lineno}" "${script_path}" |
    sed 's%\\$%%g' > "${tempfile}"

  # Do variable substitution so we can see the exact command that is failing
  echo -e \\n\\n"${timestamp} - ERROR: Script error on line $(caller) (double quotes might not show)\\n"

eval "cat <<EOF
$(<"${tempfile}")
EOF
" 2> /dev/null
}

trap handle_error ERR

# Helper functions
print_info() {
  local timestamp

  timestamp=$(date +%s)

  echo "${timestamp}" - INFO: "${1}"
}

print_error() {
  local timestamp

  timestamp=$(date +%s)

  echo "${timestamp}" - ERROR: "${1}"
  exit 1
}

print_warning() {
  local timestamp

  timestamp=$(date +%s)

  echo "${timestamp}" - WARNING: "${1}"
}

print_success() {
  local timestamp

  timestamp=$(date +%s)

  echo "${timestamp}" - SUCCESS: "${1}"
}

# Compare versions in dotted format, ie versionCompare 2.1.0 2.2.0
# from: https://stackoverflow.com/questions/4023830/how-to-compare-
#   two-strings-in-dot-separated-version-format-in-bash
versionCompare () {
  if [[ "${1}" == "${2}" ]]; then
    return 0
  fi

  local IFS=.

  # shellcheck disable=SC2206
  local i ver1=(${1}) ver2=(${2})

  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i < ${#ver2[@]}; i++)); do
    ver1[i]=0
  done

  # compare version per version
  for ((i=0; i < ${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      ver2[i]=0
    fi

    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 1
    fi

    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done

  return 0
}

helm_chart_exists() {
  local chart_name=${1}
  local namespace=${2}

  helm list -a --namespace "${namespace}"|grep "^${chart_name}"
}

helm_chart_status() {
  local chart_name=${1}
  local namespace=${2}

  helm list -a --namespace "${namespace}"|grep "^${chart_name}"|awk '{print $8}' || echo 'uninstalled'
}

helm_latest_release() {
  local chart_name=${1}
  local namespace=${2}

  helm --namespace "${namespace}" history "${chart_name}"| \
    grep -E 'deployed|superseded.*complete'|awk '{print $1}'|tail -1
}

cfn_stack_exists() {
  local stack_name=${1}

  aws cloudformation describe-stacks --stack-name "${stack_name}"
}

cfn_stack_delete_complete() {
  local stack_name=${1}

  aws cloudformation wait stack-delete-complete --stack-name "${stack_name}"
}

cfn_stack_status() {
  local stack_name=${1}

  aws cloudformation describe-stacks --stack-name "${stack_name}" |
    jq -r '.Stacks[0].StackStatus'
}

cfn_change_set_status() {
  local change_set_name=${1}
  local stack_name=${2}
  local output

  output=$(aws cloudformation describe-change-set \
    --stack-name "${stack_name}" \
    --change-set-name "${change_set_name}" 2>&1 || true)

  if [[ "${output}" =~ "ChangeSetNotFound" ]]; then
    echo NOT_FOUND
  else
    echo "${output}"|jq -r '.Status'
  fi
}

cfn_change_set_print_resource_status_reasons() {
  local change_set_name=${1}
  local stack_name=${2}

  print_warning "The cloudformation change set ${change_set_name} action failed"
  print_warning "A possible reason can be described in the following message:"

  aws cloudformation describe-change-set \
    --change-set-name "${change_set_name}" \
    --stack-name "${stack_name}" |
    jq -r '.StatusReason'

  echo
  print_warning "If the message is not clear enough, please go and check the change set status on the aws console"
}

cfn_stack_print_resource_status_reasons() {
  local stack_name=${1}

  print_warning "The cloudformation template ${stack_name} action failed"
  print_warning "A possible reason can be described in the following message:"

  aws cloudformation describe-stack-events \
    --stack-name "${stack_name}" |
    jq -r '.StackEvents[]|select(.ResourceStatusReason != null)|.ResourceStatusReason' |
    sed '/User Initiated/q' || true

  echo
  print_warning "If the message is not clear enough, please go and check the stack status on the aws console"
}

cfn_stack_get_status_progress() {
  local stack_name=${1}

  time_wait=1
  print_info "Cloud formation template status"
  while :; do
    status=$(cfn_stack_status "${stack_name}")
    case ${status} in
      CREATE_IN_PROGRESS|\
        UPDATE_IN_PROGRESS|\
        UPDATE_COMPLETE_CLEANUP_IN_PROGRESS)
        print_info "Status is ${status}"
        sleep ${time_wait};;
      ROLLBACK_IN_PROGRESS|\
        UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS|\
        UPDATE_ROLLBACK_IN_PROGRESS)
        print_warning "Status is ${status}"
        sleep ${time_wait};;
      CREATE_COMPLETE|\
        UPDATE_COMPLETE)
        print_info "Status is ${status}"
        break
        ;;
      UPDATE_ROLLBACK_COMPLETE)
        cfn_stack_print_resource_status_reasons "${stack_name}"
        print_error "Status is ${status}"
        ;;
      *)
        cfn_stack_print_resource_status_reasons "${stack_name}"
        print_error "CloudFormation stack is in an unexpected status ${status}."
        ;;
    esac

    time_wait=$(("${time_wait}"*2))
  done
}

cfn_change_set_get_status_progress() {
  local change_set_name=${1}
  local stack_name=${2}
  local status

  time_wait=1
  print_info "Cloud formation change set status"
  while :; do
    status=$(cfn_change_set_status "${change_set_name}" "${stack_name}")
    case ${status} in
      NOT_FOUND|\
        CREATE_COMPLETE|\
        DELETE_COMPLETE)
        print_info "Status is ${status}"
        break
        ;;
      CREATE_PENDING|\
        CREATE_IN_PROGRESS|\
        DELETE_PENDING|\
        DELETE_IN_PROGRESS)
        print_info "Status is ${status}"
        ;;
      DELETE_FAILED)
        cfn_change_set_print_resource_status_reasons "${change_set_name}" "${stack_name}"
        print_error "Status is ${status}"
        ;;
      FAILED)
        local message
        message=$(aws cloudformation describe-change-set \
          --change-set-name "${change_set_name}" \
          --stack-name "${stack_name}" |
          jq -r '.StatusReason')

        if [[ ${message} =~ "The submitted information didn't contain changes" ]]; then
          print_info "Status is CREATE_COMPLETE_NO_CHANGES"
          break
        else
          cfn_change_set_print_resource_status_reasons "${change_set_name}" "${stack_name}"
          print_error "Status is ${status}"
        fi
        ;;
      *)
        cfn_change_set_print_resource_status_reasons "${change_set_name}" "${stack_name}"
        print_error "CloudFormation change set is in an unexpected status ${status}."
        ;;
    esac

    time_wait=$(("${time_wait}"*2))
  done
}

check_helm_version() {
  if command -v helm > /dev/null 2>&1; then
    readonly helm_version_target=3.5.0
    local helm_version

    helm_version=$(helm version|cut -d'"' -f2|cut -b 2-)

    if ! versionCompare "${helm_version}" "${helm_version_target}"; then
      print_error "helm version should be >= 3.5.0"
    fi
  else
    print_error "helm not found. Make sure helm is installed"
  fi
}

check_aws_version() {
  if command -v aws > /dev/null 2>&1; then
    readonly aws_version_target=2.0.0
    local aws_version

    aws_version=$(aws --version|awk '{print $1}'|cut -d '/' -f2)

    if ! versionCompare "${aws_version}" "${aws_version_target}"; then
      print_error "aws version should be >= 2.0.0"
    fi
  else
    print_error "aws not found. Make sure aws-cli is installed"
  fi
}

check_sam_version() {
  if command -v sam > /dev/null 2>&1; then
    readonly sam_version_target=1.67.0
    local sam_version

    sam_version=$(sam --version|awk '{print $4}')

    if ! versionCompare "${sam_version}" "${sam_version_target}"; then
      print_error "sam version should be >= 1.67.0"
    fi
  else
    print_error "sam not found. Make sure sam-cli is installed"
  fi
}

check_jq_version() {
  if ! command -v jq > /dev/null 2>&1; then
    print_error "jq not found. Make sure jq installed"
  fi
}
