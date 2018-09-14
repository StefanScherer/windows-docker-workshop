#!/bin/bash

set -e
# we run in hashicorp/packer Alpine image
apk update
apk add jq git openssh

cd prepare-vms/azure/packer || exit

PACKER_VM_SIZE=${PACKER_VM_SIZE:-Standard_D4s_v3}
PACKER_LOCATION=${PACKER_LOCATION:-West US 2}

set -x

packer build \
  -var "vm_size=${PACKER_VM_SIZE}" \
  -var "location=${PACKER_LOCATION}" \
  -var "image_name=${PACKER_TEMPLATE}_$CIRCLE_BUILD_NUM" \
  "${PACKER_TEMPLATE}.json"
