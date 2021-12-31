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
  location = "centralus"
  name     = "rg-routes"
  tags     = local.tags
}

resource "azurerm_route_table" "rt" {
  for_each = toset([
    "agw",
    "server",
    "worker",
  ])

  disable_bgp_route_propagation = true
  location                      = azurerm_resource_group.test.location
  name                          = "rt-${each.key}-${local.instance_id}"
  resource_group_name           = azurerm_resource_group.test.name
  tags                          = local.tags
}

module "test" {
  source = "../"

  firewall_ip_address = "10.0.0.1"
  resource_group      = azurerm_resource_group.test

  route_table = azurerm_route_table.rt

  subnet = {
    hub = {
      ApplicationGatewaySubnet = {
        address_prefix = cidrsubnet("10.0.0.0/16", 4, 1)
      }
    }
    server = {
      ServerSubnet = {
        address_prefix = cidrsubnet("10.0.0.0/16", 2, 1)
      }
    }
  }
}