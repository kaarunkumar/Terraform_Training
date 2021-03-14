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
  for_each = var.server_subnets

    name                 = each.key
    resource_group_name  = azurerm_resource_group.tftrain_akrg.name
    virtual_network_name = azurerm_virtual_network.server_vnet.name
    address_prefix       = each.value
}

resource "azurerm_network_interface" "server_nic" {
  name                = "${var.server_name}-${format("%02d",count.index)}-nic"  
  location            = var.server_location
  resource_group_name = azurerm_resource_group.tftrain_akrg.name
  count               = var.server_count

  ip_configuration {
     name                          = "${var.server_name}-ip"
     subnet_id                     = azurerm_subnet.server_subnet["tf-training"].id
     private_ip_address_allocation = "dynamic"
     public_ip_address_id          = count.index == 0 ? azurerm_public_ip.server_public_ip.id : null
  }
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
  count = var.environment     == "production" ? 0 : 1
}

resource "azurerm_subnet_network_security_group_association" "server_sag" {
  network_security_group_id = azurerm_network_security_group.server_nsg.id  
  subnet_id                 = azurerm_subnet.server_subnet["tf-training"].id
}

resource "azurerm_windows_virtual_machine" "server" {
  name                  = "${var.server_name}-${format("%02d",count.index)}" 
  location              = var.server_location  
  resource_group_name   = azurerm_resource_group.tftrain_akrg.name  
  network_interface_ids = [azurerm_network_interface.server_nic[count.index].id]
  availability_set_id   = azurerm_availability_set.server_availability_set.id
  count                 = var.server_count
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

resource "azurerm_availability_set" "server_availability_set" {
  name                        = "${var.resource_prefix}-availability-set"
  location                    = var.server_location  
  resource_group_name         = azurerm_resource_group.tftrain_akrg.name
  managed                     = true 
  platform_fault_domain_count = 2
}