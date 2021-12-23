provider "azurerm" {
  features {}
}

locals {
  instance_id = "bleep-bloop"

  tags = {
    mytag       = "value"
    instance_id = local.instance_id
  }
}

resource "azurerm_resource_group" "test" {
  name     = "example"
  location = "centralus"
  tags     = local.tags
}

resource "azurerm_virtual_network" "net" {
  for_each = {
    hub = "10.0.0.0/16"
  }

  address_space       = [each.value]
  location            = azurerm_resource_group.test.location
  name                = "vnet-${each.key}-${local.instance_id}"
  resource_group_name = azurerm_resource_group.test.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    AzureBastionSubnet = cidrsubnet(azurerm_virtual_network.net["hub"].address_space.0, 2, 0)
  }

  address_prefixes     = [each.value]
  name                 = each.key
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.net["hub"].name
}

module "test" {
  source = "../"

  instance_id    = local.instance_id
  resource_group = azurerm_resource_group.test
  subnet_id      = azurerm_subnet.subnet["AzureBastionSubnet"].id
  tags           = local.tags
}