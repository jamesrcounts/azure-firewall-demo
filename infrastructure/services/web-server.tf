module "web_server" {
  source = "../modules/web-server"

  allowed_source_addresses = [local.subnet["hub"]["ApplicationGatewaySubnet"].address_prefix]
  firewall_policy_id       = local.firewall_policy_id
  instance_id              = var.env_instance_id
  resource_group           = data.azurerm_resource_group.rg
  subnet                   = local.subnet["server"]["ServerSubnet"]
  tags                     = local.tags
  zone_name                = data.azurerm_private_dns_zone.zone.name

  certificate = {
    cert_pem        = data.azurerm_key_vault_secret.import["firewall-jamesrcounts-com-cert"].value
    private_key_pem = data.azurerm_key_vault_secret.import["firewall-jamesrcounts-com-key"].value
  }
}