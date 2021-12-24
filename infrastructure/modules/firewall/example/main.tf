terraform {
  required_version = ">= 1"

  required_providers {
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "~> 0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  instance_id = "bleep-bloop"

  tags = {
    mytag       = "value"
    instance_id = local.instance_id
  }
}

resource "azurerm_resource_group" "test" {
  name     = "rg-afw-${local.instance_id}"
  location = "centralus"
  tags     = local.tags
}

resource "azurerm_virtual_network" "net" {
  for_each = {
    hub = "10.0.0.0/16"
  }

  address_space       = [each.value]
  location            = azurerm_resource_group.test.location
  name                = "vnet-${each.key}-${local.instance_id}"
  resource_group_name = azurerm_resource_group.test.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    AzureFirewallSubnet = cidrsubnet(azurerm_virtual_network.net["hub"].address_space.0, 2, 0)
  }

  address_prefixes     = [each.value]
  name                 = each.key
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.net["hub"].name
}

resource "tls_private_key" "root_ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "root_ca" {
  key_algorithm         = tls_private_key.root_ca.algorithm
  dns_names             = ["example.contoso.com"]
  private_key_pem       = tls_private_key.root_ca.private_key_pem
  validity_period_hours = 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  subject {
    common_name  = "example.contoso.com"
    organization = "Contoso Inc."
  }
}

resource "tls_private_key" "intermediate_ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "intermediate_ca" {
  key_algorithm   = tls_private_key.intermediate_ca.algorithm
  private_key_pem = tls_private_key.intermediate_ca.private_key_pem
  uris            = ["example.contoso.com"]

  subject {
    common_name  = "example.contoso.com"
    organization = "Contoso Inc."
  }
}

resource "tls_locally_signed_cert" "intermediate_ca" {
  cert_request_pem   = tls_cert_request.intermediate_ca.cert_request_pem
  ca_key_algorithm   = tls_private_key.root_ca.algorithm
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem

  validity_period_hours = 24
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "pkcs12_from_pem" "inter_pkcs12" {
  password        = ""
  cert_pem        = tls_locally_signed_cert.intermediate_ca.cert_pem
  private_key_pem = tls_private_key.intermediate_ca.private_key_pem
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "keyvault_admin" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}



resource "azurerm_key_vault" "example" {
  name                       = "kv-${local.instance_id}"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  tags                       = local.tags
  enable_rbac_authorization  = true
}

resource "azurerm_key_vault_certificate" "example" {
  name         = "imported-cert"
  key_vault_id = azurerm_key_vault.example.id

  certificate {
    contents = pkcs12_from_pem.inter_pkcs12.result
    password = ""
  }
}

module "firewall" {
  source = "../"

  ca_secret_id   = azurerm_key_vault_certificate.example.secret_id
  instance_id    = local.instance_id
  resource_group = azurerm_resource_group.test
  subnet_id      = azurerm_subnet.subnet["AzureFirewallSubnet"].id
  tags           = local.tags
}