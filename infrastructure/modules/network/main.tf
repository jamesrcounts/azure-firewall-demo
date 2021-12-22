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