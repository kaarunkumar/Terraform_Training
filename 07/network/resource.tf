provider "azurerm" {
  version = "2.2.0"
  features {}
}

resource "azurerm_resource_group" "tftrain_akrg" {
  name     = var.tftrain_akrg
  location = var.server_location
}

resource "azurerm_virtual_network" "server_vnet" {
  name                = "${var.resource_prefix}-vnet"
  location            = var.server_location
  resource_group_name = azurerm_resource_group.tftrain_akrg.name
  address_space       = [var.server_address_space]
}

resource "azurerm_subnet" "server_subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.tftrain_akrg.name
  virtual_network_name = azurerm_virtual_network.server_vnet.name
  address_prefix       = var.server_address_prefix
}

resource "azurerm_network_interface" "server_nic" {
  name                = "${var.server_name}-nic"
  location            = var.server_location
  resource_group_name = azurerm_resource_group.tftrain_akrg.name

  ip_configuration {
    name                          = "${var.server_name}-ip"
    subnet_id                     = azurerm_subnet.server_subnet.id
    private_ip_address_allocation = "dynamic"
  }
}