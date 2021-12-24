module "firewall" {
  source = "../modules/firewall"

  ca_secret_id   = data.azurerm_key_vault_secret.certificate["ca"].id
  instance_id    = var.env_instance_id
  resource_group = data.azurerm_resource_group.rg
  subnet_id      = module.networks.hub_subnet["AzureFirewallSubnet"].id
  tags           = local.tags
}