resource "azurerm_route_table" "worker" {
  disable_bgp_route_propagation = false
  location                      = data.azurerm_resource_group.rg.location
  name                          = "rt-worker-${var.env_instance_id}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  tags                          = local.tags
}

resource "azurerm_route" "worker_to_firewall" {
  address_prefix         = "0.0.0.0/0"
  name                   = "WorkerRouteFirewall"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration.0.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.worker.name
}

resource "azurerm_subnet_route_table_association" "worker_rt" {
  route_table_id = azurerm_route_table.worker.id
  subnet_id      = azurerm_subnet.subnet["WorkerSubnet"].id
}