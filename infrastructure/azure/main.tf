locals {
  tags = data.azurerm_resource_group.rg.tags
}

data "azurerm_client_config" "current" {}