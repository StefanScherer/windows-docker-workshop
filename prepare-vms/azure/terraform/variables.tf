# Settings

variable "group_name" {
  default = "docker-on-windows-workshop"
}

variable "account" {
  default = "dfm2018training"
}

variable "dns_prefix" {
  default = "dfmx1"
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

variable "admin_password" {
  default = "DockerOnWindows2018!"
}

variable "count" {
  type = "map"

  default = {
    windows = "1"
  }
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}
