module "bastion" {
  source = "../modules/bastion"

  instance_id                = var.env_instance_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  resource_group             = data.azurerm_resource_group.rg
  subnet_id                  = module.networks.subnet["hub"]["AzureBastionSubnet"].id
  tags                       = local.tags
}