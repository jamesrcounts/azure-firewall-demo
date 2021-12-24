output "network_interface" {
  description = "A network interface in the server virtual network."
  value = {
    id                 = azurerm_network_interface.server.id
    private_ip_address = azurerm_network_interface.server.private_ip_address
  }
}

output "route_table" {
  description = "A map of route table, indexed by name."
  value       = { for k, v in azurerm_route_table.rt : k => { name = v.name } }
}

output "subnet" {
  description = "A map of subnets, indexed by network, then name."
  value = {
    hub = {
      for k, v in azurerm_subnet.hub_subnet : k => {
        id             = v.id
        address_prefix = v.address_prefix
      }
    }
    server = {
      for k, v in azurerm_subnet.server_subnet : k => {
        id             = v.id
        address_prefix = v.address_prefix
      }
    }
  }
}