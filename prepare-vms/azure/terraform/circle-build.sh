#!/bin/sh
set -e

if [ -z "${CIRCLE_TAG}" ]; then
  echo "Environment variable CIRCLE_TAG must be set"
  exit 5
fi

dns_prefix=${CIRCLE_TAG%%-*}
number_of_machines=${CIRCLE_TAG#*-}

cd prepare-vms/azure/terraform
apk add pwgen

./create-passwords.sh
mkdir -p /tmp/workspace
cp machines.md /tmp/workspace

echo "DEBUG!!"
exit 0

# workaround until https://github.com/terraform-providers/terraform-provider-azurerm/pull/1471 got merged
mkdir -p .terraform/plugins/linux_amd64/
curl -L -o .terraform/plugins/linux_amd64/terraform-provider-azurerm_v1.8.0_x4 https://github.com/StefanScherer/terraform-provider-azurerm/releases/download/v1.8.0-sensitive/terraform-provider-azurerm
chmod +x .terraform/plugins/linux_amd64/terraform-provider-azurerm_v1.8.0_x4

terraform init
terraform apply \
  -var "count=$number_of_machines" \
  -var "dns_prefix=$dns_prefix" \
  -var "group_name=${dns_prefix}-${number_of_machines}-windows-docker-workshop" \
  -var "account=${dns_prefix}${number_of_machines}workshop" \
  -auto-approve
