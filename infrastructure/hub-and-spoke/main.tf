locals {
  tags = data.azurerm_resource_group.rg.tags
}

resource "azurerm_route" "server_to_agw" {
  address_prefix         = module.networks.subnet["hub"]["ApplicationGatewaySubnet"].address_prefix
  name                   = "ServerToAgw"
  next_hop_in_ip_address = module.firewall.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = module.networks.route_table["server"].name
}

resource "azurerm_route" "agw_to_server" {
  address_prefix         = module.networks.subnet["server"]["ServerSubnet"].address_prefix
  name                   = "AgwToServer"
  next_hop_in_ip_address = module.firewall.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = module.networks.route_table["agw"].name
}

// rule {
//   name             = "AllowAppService"
//   source_addresses = ["*"]
//   terminate_tls    = true

//   destination_fqdns = [
//     azurerm_app_service.webapp.default_site_hostname
//   ]

//   protocols {
//     port = 80
//     type = "Http"
//   }

//   protocols {
//     port = 443
//     type = "Https"
//   }
// }

// rule {
//   name             = "AllowWebServer"
//   source_addresses = [azurerm_subnet.subnet["ApplicationGatewaySubnet"].address_prefix]
//   terminate_tls    = false
//   # todo make true

//   destination_fqdns = [
//     local.hostname_server
//   ]

//   protocols {
//     port = 443
//     type = "Https"
//   }
// }