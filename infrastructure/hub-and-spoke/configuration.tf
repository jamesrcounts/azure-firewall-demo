# Read details about the resource group created for this project.
data "azurerm_resource_group" "rg" {
  name = "rg-${var.env_instance_id}"
}

data "azurerm_resource_group" "ops" {
  provider = azurerm.ops

  name = "rg-backend-${var.ops_instance_id}"
}

data "azurerm_key_vault" "config" {
  provider = azurerm.ops

  name                = "kv-cfg-${var.ops_instance_id}"
  resource_group_name = data.azurerm_resource_group.ops.name
}

data "azurerm_key_vault_secret" "certificate" {
  provider = azurerm.ops

  for_each = {
    ca  = "CACert"
    crt = "firewall-jamesrcounts-com-cert"
    key = "firewall-jamesrcounts-com-key"
    pfx = "firewall-jamesrcounts-com"
  }

  key_vault_id = data.azurerm_key_vault.config.id
  name         = each.value
}

data "azurerm_key_vault_certificate_data" "rootca" {
  key_vault_id = data.azurerm_key_vault.config.id
  name         = "RootCA"
}

data "azurerm_log_analytics_workspace" "main" {
  provider = azurerm.ops

  name                = "la-${var.ops_instance_id}"
  resource_group_name = data.azurerm_resource_group.ops.name
}

data "azurerm_storage_account" "log_storage_account" {
  provider = azurerm.ops

  name                = "sa${replace(var.ops_instance_id, "-", "")}"
  resource_group_name = data.azurerm_resource_group.ops.name
}