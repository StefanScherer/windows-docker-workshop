# Azure

## Install Terraform

```
brew install terraform
```

## Secrets

Get your Azure ID's and secret with `pass`

```
eval $(pass azure-terraform)
```

You will need these environment variables for terraform

```
export ARM_SUBSCRIPTION_ID="uuid"
export ARM_CLIENT_ID="uuid"
export ARM_CLIENT_SECRET="secret"
export ARM_TENANT_ID="uuid"
```

## Configure

Adjust the file `variables.tf` to your needs to choose

- location / region
- DNS prefix and suffix
- size of the VM's, default is `Standard_D2_v2`
- username and password

## Plan

```bash
terraform plan
```

## Create / Apply

```bash
terraform apply
```

If you want multiple machines, increase the count

```
terraform apply -var 'count={ windows=3 }'
```

Notice: Changing the count afterwards doesn't seem to work with Azure. So be sure to create the resource group with the correc count initially.

## Destroy

```bash
terraform destroy
```
