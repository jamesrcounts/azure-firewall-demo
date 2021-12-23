module "agw" {
  source = "../modules/application-gateway"

  providers = {
    azurerm     = azurerm
    azurerm.ops = azurerm.ops
  }

  certificate_secret_id = data.azurerm_key_vault_secret.certificate["pfx"].id
  backend_addresses     = ["192.168.0.1"]
  host_name             = "test.contoso.com"
  instance_id           = var.env_instance_id
  subnet_id             = module.networks.hub_subnet["ApplicationGatewaySubnet"].id
  tags                  = local.tags

  resource_groups = {
    env = data.azurerm_resource_group.rg
    ops = data.azurerm_resource_group.ops
  }
}