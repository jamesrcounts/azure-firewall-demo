data "azurerm_key_vault" "config" {
  provider = azurerm.ops

  name                = "kv-${var.ops_instance_id}"
  resource_group_name = data.azurerm_resource_group.ops.name
}

data "azurerm_key_vault_secret" "certificate" {
  provider = azurerm.ops

  for_each = {
    prd = "firewall-jamesrcounts-com"
  }

  key_vault_id = data.azurerm_key_vault.config.id
  name         = each.value
}