# Settings

variable "account" {
  default = "dc-mta"
}

variable "dns_prefix" {
  default = "dc-mta"
}

variable "location" {
  // default = "northeurope"
  default = "centralus"
}

variable "azure_dns_suffix" {
    description = "Azure DNS suffix for the Public IP"
    default = "cloudapp.azure.com"
}

variable "admin_username" {
  default = "testadmin"
}

variable "admin_password" {
  default = "Password1234!"
}

variable "count" {
  type = "map"

  default = {
    windows = "1"
  }
}

variable "vm_size" {
  default = "Standard_D2_v2"
}
