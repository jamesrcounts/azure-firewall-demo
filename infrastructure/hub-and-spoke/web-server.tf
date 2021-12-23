module "web_server" {
  source = "../modules/web-server"

  instance_id          = var.env_instance_id
  network_interface_id = module.networks.network_interface_id
  resource_group       = data.azurerm_resource_group.rg
  tags                 = local.tags

  certificate = {
    cert_pem        = data.azurerm_key_vault_secret.certificate["crt"].value
    private_key_pem = data.azurerm_key_vault_secret.certificate["key"].value
  }
}