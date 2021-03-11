provider "azurerm" {
  version = "2.2.0"
  features {}
}

resource "azurerm_resource_group" "tftrain_akrg" {
  name     = "tftrain_akrg"
  location = "westus2"
}