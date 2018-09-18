# Settings

variable "dns_prefix" {
  default = "wdw"
}

variable "count" {
  default = "1"
}

variable "group_name" {
  default = "chocolateyfest-docker-workshop"
}

variable "account" {
  default = "chocotraining"
}

variable "location" {
  default = "westus2"
}

variable "azure_dns_suffix" {
  description = "Azure DNS suffix for the Public IP"
  default     = "cloudapp.azure.com"
}

variable "admin_username" {
  default = "training"
}

variable "workshop_image" {
  default = "windows_2019_docker_azure_324"
}

variable "vm_size" {
  default = "Standard_D4s_v3"
}
