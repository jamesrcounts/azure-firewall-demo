locals {
  base_range = "10.0.0.0/16"
}

resource "azurerm_virtual_network" "net" {
  for_each = {
    hub    = cidrsubnet(local.base_range, 2, 0)
    worker = cidrsubnet(local.base_range, 2, 2)
    server = cidrsubnet(local.base_range, 2, 3)
  }

  address_space       = [each.value]
  location            = var.resource_group.location
  name                = "vnet-${each.key}-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = toset(["worker", "server"])

  name                      = "hub-to-${each.key}"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.net["hub"].name
  remote_virtual_network_id = azurerm_virtual_network.net[each.value].id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = toset(["worker", "server"])

  name                      = "${each.key}-to-hub"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.net[each.value].name
  remote_virtual_network_id = azurerm_virtual_network.net["hub"].id
}

resource "azurerm_subnet" "hub_subnet" {
  for_each = {
    AzureBastionSubnet       = 0
    AzureFirewallSubnet      = 1
    ApplicationGatewaySubnet = 2
  }

  address_prefixes     = [cidrsubnet(azurerm_virtual_network.net["hub"].address_space.0, 2, each.value)]
  name                 = each.key
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.net["hub"].name
}

resource "azurerm_subnet" "server_subnet" {
  for_each = {
    ServerSubnet = 3
  }

  address_prefixes     = [cidrsubnet(azurerm_virtual_network.net["server"].address_space.0, 2, each.value)]
  name                 = each.key
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.net["server"].name
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  priority                    = 2048
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = azurerm_subnet.hub_subnet["ApplicationGatewaySubnet"].address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.web.name
}

# TODO Enable once AGW is up
// resource "azurerm_network_security_rule" "default_deny_in" {
//   name                        = "default-deny-in"
//   priority                    = 4096
//   direction                   = "Inbound"
//   access                      = "Deny"
//   protocol                    = "*"
//   source_port_range           = "*"
//   destination_port_range      = "*"
//   source_address_prefix       = "*"
//   destination_address_prefix  = "*"
//   resource_group_name         = var.resource_group.name
//   network_security_group_name = azurerm_network_security_group.web.name
// }

# TODO Enable once firewall is up
// resource "azurerm_network_security_rule" "default_deny_out" {
//   name                        = "default-deny-out"
//   priority                    = 4096
//   direction                   = "Outbound"
//   access                      = "Deny"
//   protocol                    = "*"
//   source_port_range           = "*"
//   destination_port_range      = "*"
//   source_address_prefix       = "*"
//   destination_address_prefix  = "*"
//   resource_group_name         = var.resource_group.name
//   network_security_group_name = azurerm_network_security_group.web.name
// }

resource "azurerm_public_ip" "example" {
  name                = "pip-${var.instance_id}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_network_interface" "server" {
  location            = var.resource_group.location
  name                = "nic-server-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags

  ip_configuration {
    name                          = "ServerIPConfiguration"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
    subnet_id                     = azurerm_subnet.server_subnet["ServerSubnet"].id
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_to_server" {
  subnet_id                 = azurerm_subnet.server_subnet["ServerSubnet"].id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_route_table" "server" {
  disable_bgp_route_propagation = true
  location                      = var.resource_group.location
  name                          = "rt-server-${var.instance_id}"
  resource_group_name           = var.resource_group.name
  tags                          = var.tags
}

resource "azurerm_subnet_route_table_association" "server" {
  route_table_id = azurerm_route_table.server.id
  subnet_id      = azurerm_subnet.server_subnet["ServerSubnet"].id
}

// resource "azurerm_route" "agw_thru_firewall" {
//   address_prefix         = azurerm_subnet.subnet["ApplicationGatewaySubnet"].address_prefix
//   name                   = "AgwThruFirewall"
//   next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration.0.private_ip_address
//   next_hop_type          = "VirtualAppliance"
//   resource_group_name    = var.resource_group.name
//   route_table_name       = azurerm_route_table.server.name
// }
