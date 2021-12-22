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

resource "azurerm_network_security_rule" "default_deny_in" {
  name                        = "default-deny-in"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_rule" "default_deny_out" {
  name                        = "default-deny-out"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.web.name
}