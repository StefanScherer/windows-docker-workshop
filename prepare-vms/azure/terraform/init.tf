# Configure the Microsoft Azure Provider
provider "azurerm" {}

# Create a resource group
resource "azurerm_resource_group" "global" {
  location = "${var.location}"
  name     = "${var.group_name}"
}

# Create a storage account
resource "azurerm_storage_account" "global" {
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = "${var.location}"
  name                     = "${var.account}"
  resource_group_name      = "${azurerm_resource_group.global.name}"
}

data "azurerm_image" "workshop_image" {
  name                = "${var.workshop_image}"
  resource_group_name = "windows-docker-workshop-images"
}
