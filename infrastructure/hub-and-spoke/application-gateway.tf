module "agw" {
  source = "../modules/application-gateway"

  providers = {
    azurerm     = azurerm
    azurerm.ops = azurerm.ops
  }

  certificate_secret_id      = data.azurerm_key_vault_secret.certificate["pfx"].id
  backend_addresses          = [module.networks.network_interface.private_ip_address]
  host_name                  = "firewall.jamesrcounts.com"
  instance_id                = var.env_instance_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  subnet_id                  = module.networks.subnet["hub"]["ApplicationGatewaySubnet"].id
  tags                       = local.tags

  resource_groups = {
    env = data.azurerm_resource_group.rg
    ops = data.azurerm_resource_group.ops
  }
}