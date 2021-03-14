output "pip" {
 value = azurerm_public_ip.server_public_ip
}


output "my_vm_public_IP" {
 value = azurerm_public_ip.server_public_ip.ip_address
}