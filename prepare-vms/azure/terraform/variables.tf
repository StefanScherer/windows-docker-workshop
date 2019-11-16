# Settings

variable "dns_prefix" {
  default = "xcel"
}

variable "count" {
  default = "1"
}

variable "group_name" {
  default = "windows-docker-workshop"
}

variable "account" {
  default = "xcelerate"
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
  default = "windows_2019_878"
}

variable "vm_size" {
  default = "Standard_D4s_v3"
}
