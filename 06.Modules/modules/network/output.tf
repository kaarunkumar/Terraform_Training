output "my_nic" {
  value = azurerm_network_interface.my_nic.*.id
}