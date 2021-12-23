output "network_interface_id" {
  description = "A network interface in the server virtual network."
  value       = azurerm_network_interface.server.id
}

output "hub_subnet" {
  description = "A map of subnets, indexed by name."
  value       = { for k, v in azurerm_subnet.hub_subnet : k => { id = v.id } }
}