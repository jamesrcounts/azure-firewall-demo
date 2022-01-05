module "web_server" {
  source = "../modules/web-server"

  azure_firewall_subnet_cidrs = [local.subnet["hub"]["AzureFirewallSubnet"].address_prefix]
  firewall_policy_id          = local.firewall_policy_id
  instance_id                 = var.env_instance_id
  nsg_name                    = local.nsg["server"].name
  resource_group              = data.azurerm_resource_group.rg
  subnet                      = local.subnet["server"]["ServerSubnet"]
  tags                        = local.tags
  zone_name                   = data.azurerm_private_dns_zone.zone.name

  allowed_source_addresses = [
    local.subnet["hub"]["ApplicationGatewaySubnet"].address_prefix,
    local.subnet["hub"]["AzureFirewallSubnet"].address_prefix,
  ]

  certificate = {
    cert_pem        = data.azurerm_key_vault_secret.import["firewall-jamesrcounts-com-cert"].value
    private_key_pem = data.azurerm_key_vault_secret.import["firewall-jamesrcounts-com-key"].value
  }
}