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
  name     = "rg-appservice"
  location = "centralus"
  tags     = local.tags
}

module "test" {
  source = "../"

  instance_id    = local.instance_id
  resource_group = azurerm_resource_group.test
  tags           = local.tags
}

output "site" {
  value = module.test.default_site_hostname
}