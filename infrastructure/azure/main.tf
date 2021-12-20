locals {
  tags            = data.azurerm_resource_group.rg.tags
  hostname_server = "firewall.jamesrcounts.com"
}

data "azurerm_client_config" "current" {}