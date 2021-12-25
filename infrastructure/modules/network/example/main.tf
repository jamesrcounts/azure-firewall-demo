provider "azurerm" {
  features {}
}

locals {
  tags = {
    mytag       = "value"
    instance_id = "bleep-bloop"
  }
}

resource "azurerm_resource_group" "test" {
  name     = "rg-network-example"
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

resource "azurerm_storage_account" "example" {
  name                     = "sableepbloop"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = local.tags
}

module "test" {
  source = "../"

  resource_group          = azurerm_resource_group.test
  tags                    = azurerm_resource_group.test.tags
  instance_id             = azurerm_resource_group.test.tags["instance_id"]
  log_analytics_workspace = azurerm_log_analytics_workspace.example
  log_storage_account_id  = azurerm_storage_account.example.id
}

output "network_interface_id" {
  value = module.test.network_interface.id
}

output "bastion_subnet_id" {
  value = module.test.subnet["hub"]["AzureBastionSubnet"].id
}