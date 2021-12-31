locals {
  internet_prefix = "0.0.0.0/0"
}

resource "azurerm_route" "agw_to_server" {
  address_prefix         = var.subnet["server"]["ServerSubnet"].address_prefix
  name                   = "AgwToServer"
  next_hop_in_ip_address = var.firewall_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = var.resource_group.name
  route_table_name       = var.route_table["agw"].name
}

resource "azurerm_route" "worker_to_internet" {
  address_prefix         = local.internet_prefix
  name                   = "WorkerToInternet"
  next_hop_in_ip_address = var.firewall_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = var.resource_group.name
  route_table_name       = var.route_table["worker"].name
}
