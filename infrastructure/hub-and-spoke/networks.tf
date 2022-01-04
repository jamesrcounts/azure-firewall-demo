module "networks" {
  source = "../modules/network"

  instance_id             = var.env_instance_id
  log_analytics_workspace = data.azurerm_log_analytics_workspace.main
  log_storage_account_id  = data.azurerm_storage_account.log_storage_account.id
  resource_group          = data.azurerm_resource_group.rg
  tags                    = local.tags
  zone_name               = "jamesrcounts.com"
}