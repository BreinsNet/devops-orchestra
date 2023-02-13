#!/bin/bash

# Activate tests
TEST=${TEST:-false}

if [[ ${TEST} = "true" ]]; then
  shopt -s expand_aliases

  alias ssh="echo ssh"
  alias scp="echo scp"
  alias aws="echo aws"
  alias sam="echo sam"
  alias helm="echo helm"
  alias cp="echo cp"
  alias git="echo git"
  alias npm="echo npm"
  alias node="echo node"
  alias which="echo which"
  alias cat="echo cat"
  alias jq="echo jq"
  alias bats="echo bats"
  alias find="echo file1 file2 file3"
  alias python="echo python"
  alias pip="echo pip"
  alias cfn-flip="echo cfn-flip"
  alias timeout="echo timeout"
  alias klar="echo klar"
  alias bash="echo bash"
  alias zip="echo zip"

  # This is to prevent echo|echo to fail
  set +o pipefail

  if [[ ! -d test/ ]]; then
    mkdir test
  fi

  # python specific tests
  echo 'test==1.0' > test/requirements.txt
  touch lambda-python-test-test.zip
  touch test1
  touch test2
  touch Dockerfile

  # node specific tests
  touch test/package.json
  touch test/package-lock.json
  touch lambda-node-test-test.zip

  docker() {
    if [[ $1 == manifest ]]; then
      return 1
    else
      return 0
    fi
  }

  cfn_stack_exists() {
    return 0
  }

  cfn_stack_status() {
    echo CREATE_COMPLETE
  }

  cfn_change_set_status() {
    echo CREATE_COMPLETE
  }

  cfn_stack_delete_complete() {
    return 0
  }

  cfn_stack_print_resource_status_reasons() {
    return 0
  }

  cfn_change_set_print_resource_status_reasons() {
    return 0
  }

  helm_chart_exists() {
    return 0
  }

  versionCompare() {
    return 0
  }

  # Print env vars to see if thehy can be passed
  env
fi
