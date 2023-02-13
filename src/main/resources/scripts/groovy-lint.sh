#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

readonly REPOSITORY_NAME=501584834092.dkr.ecr.eu-west-1.amazonaws.com/ecom-su-ecr-repository/npm-groovy-lint:9
declare USER
declare GROUP

USER=$(id -u)
GROUP=$(id -g)

docker run --rm \
  --user="${USER}":"${GROUP}" \
  --workdir=/tmp \
  --volume="${PWD}":/tmp \
  ${REPOSITORY_NAME} --failon info

print_success "The task has run successfully"
