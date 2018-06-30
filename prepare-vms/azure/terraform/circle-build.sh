#!/bin/sh
set -e

cd prepare-vms/azure/terraform
apk add pwgen

number_of_machines=1
./create-passwords.sh "$number_of_machines"

# workaround until https://github.com/terraform-providers/terraform-provider-azurerm/pull/1471 got merged
mkdir -p .terraform/plugins/linux_amd64/
curl -L -o .terraform/plugins/linux_amd64/terraform-provider-azurerm_v1.8.0_x4 https://github.com/StefanScherer/terraform-provider-azurerm/releases/download/v1.8.0-sensitive/terraform-provider-azurerm
chmod +x .terraform/plugins/linux_amd64/terraform-provider-azurerm_v1.8.0_x4

terraform init

echo "Debug"
echo list absolute
ls -l /root/project/prepare-vms/azure/terraform/.terraform/plugins/linux_amd64/
echo list relative
ls -l .terraform/plugins/linux_amd64/

terraform apply -var "count=$number_of_machines" -auto-approve

echo "Uploading machines.md to Slack"
curl -F file=@machines.md "https://slack.com/api/files.upload?token=${SLACK_TOKEN}&channels=%40stefanscherer&pretty=1"
