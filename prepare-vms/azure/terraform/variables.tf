# Settings

variable "group_name" {
  default = "docker-on-windows-workshop"
}

variable "account" {
  default = "dfm2018training"
}

variable "dns_prefix" {
  default = "ba"
}

variable "location" {
  default = "westeurope"
}

variable "azure_dns_suffix" {
  description = "Azure DNS suffix for the Public IP"
  default     = "cloudapp.azure.com"
}

variable "admin_username" {
  default = "training"
}

variable "workshop_image" {
  default = "windows_2016_72"
}

variable "count" {
  default = "1"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}
