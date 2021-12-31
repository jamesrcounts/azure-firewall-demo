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

resource "azurerm_log_analytics_workspace" "example" {
  name                = "acctest-01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_firewall_policy" "example" {
  location            = azurerm_resource_group.test.location
  name                = "example"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"
}

module "test" {
  source = "../"

  firewall_policy_id         = azurerm_firewall_policy.example.id
  instance_id                = local.instance_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  resource_group             = azurerm_resource_group.test
  tags                       = local.tags
}

output "site" {
  value = module.test.default_site_hostname
}