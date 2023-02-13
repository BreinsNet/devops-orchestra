#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

PATH=${PATH}:${PWD}/build/test/bin

if [[ -d test ]] || [[ ${TEST} = "true" ]]; then
  # Build the bats environment
  if [[ -d build/test ]]; then
    rm -rf build/test
  fi

  tar -C build/ -x -f build/bats.tar
  cp -r test build

  # Running tests
  print_info "Running bats tests under test/"
  echo

  cd build && bats test

  echo
  print_success "The task has run successfully"
else
  print_warning "No tests defined under test/"
fi
