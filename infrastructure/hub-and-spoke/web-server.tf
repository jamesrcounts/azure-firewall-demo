module "web_server" {
  source = "../modules/web-server"

  allowed_source_addresses = [module.networks.subnet["hub"]["ApplicationGatewaySubnet"].address_prefix]
  firewall_policy_id       = module.firewall.firewall_policy_id
  instance_id              = var.env_instance_id
  resource_group           = data.azurerm_resource_group.rg
  subnet                   = module.networks.subnet["server"]["ServerSubnet"]
  tags                     = local.tags

  certificate = {
    cert_pem        = data.azurerm_key_vault_secret.certificate["crt"].value
    private_key_pem = data.azurerm_key_vault_secret.certificate["key"].value
  }
}