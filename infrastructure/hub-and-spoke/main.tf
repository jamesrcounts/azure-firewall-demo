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

// resource "azurerm_route" "server_to_internet" {
//   address_prefix         = "0.0.0.0/0"
//   name                   = "ServerToInternet"
//   next_hop_in_ip_address = module.firewall.private_ip_address
//   next_hop_type          = "VirtualAppliance"
//   resource_group_name    = data.azurerm_resource_group.rg.name
//   route_table_name       = module.networks.route_table["server"].name
// }

resource "azurerm_route" "agw_to_server" {
  address_prefix         = module.networks.subnet["server"]["ServerSubnet"].address_prefix
  name                   = "AgwToServer"
  next_hop_in_ip_address = module.firewall.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = module.networks.route_table["agw"].name
}


resource "azurerm_firewall_policy_rule_collection_group" "rules" {
  name               = "webserver"
  firewall_policy_id = module.firewall.firewall_policy_id
  priority           = 500

  network_rule_collection {
    name     = "AgwToServer"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "AllowWebServer"
      protocols             = ["TCP", "UDP"]
      source_addresses      = [module.networks.subnet["hub"]["ApplicationGatewaySubnet"].address_prefix]
      destination_addresses = [module.networks.subnet["server"]["ServerSubnet"].address_prefix]
      destination_ports     = ["443"]
    }
  }

  // application_rule_collection {
  //   name     = ""
  //   priority = 129
  //   action   = "Allow"

  //   rule {
  //     name             = ""
  //     terminate_tls    = false
  //     # todo make true

  //     destination_fqdns = [
  //       "firewall.jamesrcounts.com"
  //     ]

  //     protocols {
  //       port = 443
  //       type = "Https"
  //     }
  //   }
  // }
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

