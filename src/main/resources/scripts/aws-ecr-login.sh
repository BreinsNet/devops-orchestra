#!/usr/bin/env bash

# shellcheck disable=SC1090,SC2046
source <(cat $(dirname -- "${BASH_SOURCE[0]}")/lib/*sh)

# Check tools
check_aws_version
check_jq_version

declare AWS_REGION
declare AWS_ACCOUNT

AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
AWS_ACCOUNT=$(aws sts get-caller-identity|jq --raw-output .Account)

aws ecr get-login-password --region "${AWS_REGION}" |
  docker login --username AWS --password-stdin "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

print_success "The task has run successfully"
