provider "azurerm" {
  version = "2.2.0"
  features {}
}

resource "azurerm_resource_group" "tftrain_akrg" {
  name     = var.tftrain_akrg
  location = var.server_location
}

resource "azurerm_public_ip" "server_public_ip" {
  name                = "${var.resource_prefix}-public-ip"
  location            = var.server_location  
  resource_group_name = azurerm_resource_group.tftrain_akrg.name  
  allocation_method   = var.environment == "production" ? "Static" : "Dynamic"
}

resource "azurerm_network_security_group" "server_nsg" {
  name                = "${var.resource_prefix}-nsg"
  location            = var.server_location  
  resource_group_name = azurerm_resource_group.tftrain_akrg.name    
}

resource "azurerm_network_security_rule" "server_nsg_rule_rdp" {
  name                        = "RDP Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tftrain_akrg.name   
  network_security_group_name = azurerm_network_security_group.server_nsg.name
}

resource "azurerm_network_interface_security_group_association" "server_nsg_association" {
  network_security_group_id = azurerm_network_security_group.server_nsg.id  
  network_interface_id      = azurerm_network_interface.server_nic.id
}

resource "azurerm_windows_virtual_machine" "server" {
  name                  = var.server_name
  location              = var.server_location  
  resource_group_name   = azurerm_resource_group.tftrain_akrg.name  
  network_interface_ids = [azurerm_network_interface.server_nic.id]
  size                  = "Standard_B1s"
  admin_username        = "testtfserver"
  admin_password        = "Passw0rd1234"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServerSemiAnnual"
    sku       = "Datacenter-Core-1709-smalldisk"
    version   = "latest"
  }

}