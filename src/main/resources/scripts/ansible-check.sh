#!/bin/bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Bash input variables:
readonly PLAYBOOK=${1:-}
readonly INVENTORY=${2:-}
readonly HOST=${3:-}
readonly SRC_PATH=${4}
readonly DIFF=${5:-false}

# Parameter validations:
if [[ -z ${PLAYBOOK} ]] || [[ -z ${INVENTORY} ]] || [[ -z $HOST ]]; then
  echo "usage: ${0} PLAYBOOK INVENTORY HOST SRC_PATH [DIFF]"
  exit 1
fi

if [[ ! -d ${SRC_PATH} ]]; then
  print_error "Ansible source path don't exist"
fi

# Optional parameters:
EXTRA_PARAMS=""

if ${DIFF}; then
  EXTRA_PARAMS="--diff"
fi

# Do the thing
cd "${SRC_PATH}" || return

ssh "$HOST" 'if [[ ! -d /tmp/ansible ]]; then mkdir /tmp/ansible; fi'

tar --gzip \
  --create \
  --exclude=build \
  --exclude=build.gradle \
  --file ansible.tar.gz ./*

scp ansible.tar.gz "$HOST:/tmp/ansible/ansible.tar.gz" > /dev/null

# shellcheck disable=SC2029
ssh "$HOST" "
  cd /tmp/ansible
  ls|grep -v ansible.tar.gz|xargs rm -rf
  tar zxf ansible.tar.gz
  sudo ansible-playbook --check ${EXTRA_PARAMS} -i ${INVENTORY} ${PLAYBOOK}
"

print_success "The task has run successfully"
