#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tools
check_aws_version
check_jq_version

# Bash input variables:
readonly REPOSITORY_NAME=${1:-}
readonly IMAGE_TAG=${2:-}

# Parameter validations:
if [[ -z ${REPOSITORY_NAME} ]] || [[ -z ${IMAGE_TAG} ]]; then
  echo "usage: ${0} REPOSITORY_NAME IMAGE_TAG"
  echo
  echo Optional environment variables:
  echo "- REPOSITORY_NAME: The repository name"
  echo "- IMAGE_TAG: The image tag"
  exit 1
fi

if aws ecr describe-images --repository-name="${REPOSITORY_NAME}" \
  --image-ids=imageTag="${IMAGE_TAG}" > /dev/null 2>&1; then
  echo -n "true"
else
  echo -n "false"
fi
