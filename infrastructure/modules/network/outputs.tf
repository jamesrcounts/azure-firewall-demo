output "network_interface_id" {
  description = "A network interface in the server virtual network."
  value       = azurerm_network_interface.server.id
}