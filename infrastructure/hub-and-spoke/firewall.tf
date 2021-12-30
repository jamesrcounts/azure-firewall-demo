module "firewall" {
  source = "../modules/firewall"

  ca_secret_id               = data.azurerm_key_vault_secret.certificate["ca"].id
  instance_id                = var.env_instance_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  resource_group             = data.azurerm_resource_group.rg
  subnet_id                  = module.networks.subnet["hub"]["AzureFirewallSubnet"].id
  tags                       = local.tags
}