output "network_interface" {
  description = "The server's network interface information."
  value = {
    id                 = azurerm_network_interface.server.id
    private_ip_address = azurerm_network_interface.server.private_ip_address
  }
}