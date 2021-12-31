module "app_service" {
  source = "../modules/app-service"

  firewall_policy_id         = module.firewall.firewall_policy_id
  instance_id                = var.env_instance_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  resource_group             = data.azurerm_resource_group.rg
  tags                       = local.tags
}