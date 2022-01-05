provider "azurerm" {
  features {}
}

locals {
  instance_id = "bleep-bloop"
  tags        = azurerm_resource_group.test.tags
}

resource "azurerm_resource_group" "test" {
  name     = "example"
  location = "centralus"
  tags = {
    mytag       = "value"
    instance_id = local.instance_id
  }
}

resource "azurerm_virtual_network" "net" {
  for_each = {
    server = "10.0.0.0/16"
  }

  address_space       = [each.value]
  location            = azurerm_resource_group.test.location
  name                = "vnet-${each.key}-${local.instance_id}"
  resource_group_name = azurerm_resource_group.test.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    ServerSubnet             = cidrsubnet(azurerm_virtual_network.net["server"].address_space.0, 2, 0)
    ApplicationGatewaySubnet = cidrsubnet(azurerm_virtual_network.net["server"].address_space.0, 2, 1)
    AzureFirewallSubnet      = cidrsubnet(azurerm_virtual_network.net["server"].address_space.0, 2, 2)
  }

  address_prefixes     = [each.value]
  name                 = each.key
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.net["server"].name
}

resource "tls_private_key" "example" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "example" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "azurerm_firewall_policy" "example" {
  location            = azurerm_resource_group.test.location
  name                = "example"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"
}

resource "azurerm_private_dns_zone" "zone" {
  name                = "example.com"
  resource_group_name = azurerm_resource_group.test.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags                = local.tags
}

module "test" {
  source = "../"

  application_gateway_subnet_cidrs = azurerm_subnet.subnet["ApplicationGatewaySubnet"].address_prefixes
  azure_firewall_subnet_cidrs      = azurerm_subnet.subnet["AzureFirewallSubnet"].address_prefixes
  firewall_policy_id               = azurerm_firewall_policy.example.id
  instance_id                      = local.instance_id
  resource_group                   = azurerm_resource_group.test
  subnet                           = azurerm_subnet.subnet["ServerSubnet"]
  tags                             = local.tags
  zone_name                        = azurerm_private_dns_zone.zone.name
  nsg_name                         = azurerm_network_security_group.web.name

  certificate = {
    cert_pem        = tls_self_signed_cert.example.cert_pem
    private_key_pem = tls_private_key.example.private_key_pem
  }
}