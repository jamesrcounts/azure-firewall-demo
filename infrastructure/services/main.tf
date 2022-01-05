locals {
  ca_certificate     = nonsensitive(data.azurerm_key_vault_secret.import["RootCA"].value)
  firewall_policy_id = nonsensitive(data.azurerm_key_vault_secret.import["firewall-policy-id"].value)
  host_name          = "firewall.jamesrcounts.com"
  nsg                = jsondecode(nonsensitive(data.azurerm_key_vault_secret.import["nsg"].value))
  subnet             = jsondecode(nonsensitive(data.azurerm_key_vault_secret.import["subnet"].value))
  tags               = data.azurerm_resource_group.rg.tags
}
