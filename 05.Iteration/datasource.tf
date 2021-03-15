data "azurerm_resource_group" "tftrain_akrg" {
  name = "tftrain_akrg"
}

output "resource_group_id" {
  value = data.azurerm_resource_group.tftrain_akrg.id
}

data "azurerm_network_interface" "server_nic" {
  name                = "acctest-nic"
  resource_group_name = "tftrain_akrg"
}

output "network_interface_id" {
  value = data.azurerm_network_interface.server_nic.id
}