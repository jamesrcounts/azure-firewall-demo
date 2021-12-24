output "network_interface" {
  description = "A network interface in the server virtual network."
  value = {
    id                 = azurerm_network_interface.server.id
    private_ip_address = azurerm_network_interface.server.private_ip_address
  }
}

output "hub_subnet" {
  description = "A map of subnets, indexed by name."
  value       = { for k, v in azurerm_subnet.hub_subnet : k => { id = v.id } }
}