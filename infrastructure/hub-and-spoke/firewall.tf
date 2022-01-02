module "firewall" {
  source = "../modules/firewall"

  providers = {
    azurerm     = azurerm
    azurerm.ops = azurerm.ops
  }

  ca_secret_id               = data.azurerm_key_vault_secret.certificate["ca"].id
  instance_id                = var.env_instance_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  subnet_id                  = module.networks.subnet["hub"]["AzureFirewallSubnet"].id
  tags                       = local.tags

  resource_groups = {
    env = data.azurerm_resource_group.rg
    ops = data.azurerm_resource_group.ops
  }
}