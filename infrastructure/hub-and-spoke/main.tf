locals {
  host_name = "firewall.jamesrcounts.com"
  tags      = data.azurerm_resource_group.rg.tags
}

resource "azurerm_route" "server_to_agw" {
  address_prefix         = module.networks.subnet["hub"]["ApplicationGatewaySubnet"].address_prefix
  name                   = "ServerToAgw"
  next_hop_in_ip_address = module.firewall.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = module.networks.route_table["server"].name
}

resource "azurerm_route" "server_to_internet" {
  address_prefix         = "0.0.0.0/0"
  name                   = "ServerToInternet"
  next_hop_in_ip_address = module.firewall.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = module.networks.route_table["server"].name
}

resource "azurerm_route" "worker_to_internet" {
  address_prefix         = "0.0.0.0/0"
  name                   = "WorkerToInternet"
  next_hop_in_ip_address = module.firewall.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = module.networks.route_table["worker"].name
}

resource "azurerm_route" "agw_to_server" {
  address_prefix         = module.networks.subnet["server"]["ServerSubnet"].address_prefix
  name                   = "AgwToServer"
  next_hop_in_ip_address = module.firewall.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = module.networks.route_table["agw"].name
}






