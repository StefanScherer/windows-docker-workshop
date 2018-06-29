# Azure

## Build VM image with Packer

```
cd packer
packer build
```

## Create workshop VM's with Terraform

```
cd terraform
terraform init
terraform plan
terraform apply -var 'count={ windows=3 }'
```

## Destroy

```bash
terraform destroy
```
