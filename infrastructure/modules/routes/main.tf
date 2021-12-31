resource "azurerm_route" "agw_to_server" {
  address_prefix         = var.subnet["server"]["ServerSubnet"].address_prefix
  name                   = "AgwToServer"
  next_hop_in_ip_address = var.firewall_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = var.resource_group.name
  route_table_name       = var.route_table["agw"].name
}


