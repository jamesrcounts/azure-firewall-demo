provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-network-example"
  location = "centralus"
  tags = {
    mytag       = "value"
    instance_id = "bleep-bloop"
  }
}

module "test" {
  source = "../"

  resource_group = azurerm_resource_group.test
  tags           = azurerm_resource_group.test.tags
  instance_id    = azurerm_resource_group.test.tags["instance_id"]
}

output "network_interface_id" {
  value = module.test.network_interface_id
}

output "bastion_subnet_id" {
  value = module.test.hub_subnet["AzureBastionSubnet"].id
}