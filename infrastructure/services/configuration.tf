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

data "azurerm_key_vault_secret" "import" {
  provider = azurerm.ops

  for_each = toset([
    "firewall-jamesrcounts-com",
    "firewall-jamesrcounts-com-cert",
    "firewall-jamesrcounts-com-key",
    "firewall-policy-id",
    "subnet",
    "RootCA",
  ])

  key_vault_id = data.azurerm_key_vault.config.id
  name         = each.key
}

data "azurerm_log_analytics_workspace" "main" {
  provider = azurerm.ops

  name                = "la-${var.ops_instance_id}"
  resource_group_name = data.azurerm_resource_group.ops.name
}