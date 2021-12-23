module "bastion" {
  source = "../modules/bastion"

  instance_id    = var.env_instance_id
  resource_group = data.azurerm_resource_group.rg
  subnet_id      = module.networks.hub_subnet["AzureBastionSubnet"].id
  tags           = local.tags
}