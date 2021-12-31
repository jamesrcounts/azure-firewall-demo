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
  }

  address_prefixes     = [each.value]
  name                 = each.key
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.net["server"].name
}

// resource "azurerm_network_interface" "server" {
//   location            = azurerm_resource_group.test.location
//   name                = "nic-server-${local.instance_id}"
//   resource_group_name = azurerm_resource_group.test.name
//   tags                = local.tags

//   ip_configuration {
//     name                          = "ServerIPConfiguration"
//     private_ip_address_allocation = "dynamic"
//     subnet_id                     = azurerm_subnet.subnet["ServerSubnet"].id
//   }
// }

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

module "test" {
  source = "../"

  allowed_source_addresses = [azurerm_subnet.subnet["ApplicationGatewaySubnet"].address_prefix]
  firewall_policy_id       = azurerm_firewall_policy.example.id
  instance_id              = local.instance_id
  resource_group           = azurerm_resource_group.test
  subnet                   = azurerm_subnet.subnet["ServerSubnet"]
  tags                     = local.tags

  certificate = {
    cert_pem        = tls_self_signed_cert.example.cert_pem
    private_key_pem = tls_private_key.example.private_key_pem
  }
}