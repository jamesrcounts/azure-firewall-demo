resource "azurerm_key_vault_secret" "export" {
  provider = azurerm.ops

  for_each = {
    "firewall-policy-id" = module.firewall.firewall_policy_id
    "firewall-public-ip" = module.firewall.public_ip_address
    "subnet"             = jsonencode(module.networks.subnet)
    # "nsg"                = jsonencode(module.networks.nsg)
  }

  key_vault_id = data.azurerm_key_vault.config.id
  name         = each.key
  value        = each.value
}
