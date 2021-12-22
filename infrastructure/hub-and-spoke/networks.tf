module "networks" {
  source = "../modules/network"

  instance_id    = var.env_instance_id
  resource_group = data.azurerm_resource_group.rg
  tags           = local.tags
}