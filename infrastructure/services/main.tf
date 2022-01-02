locals {
  ca_certificate     = nonsensitive(data.azurerm_key_vault_secret.import["RootCA"].value)
  host_name          = "firewall.jamesrcounts.com"
  tags               = data.azurerm_resource_group.rg.tags
  firewall_policy_id = nonsensitive(data.azurerm_key_vault_secret.import["firewall-policy-id"].value)
  subnet             = jsondecode(nonsensitive(data.azurerm_key_vault_secret.import["subnet"].value))
}
