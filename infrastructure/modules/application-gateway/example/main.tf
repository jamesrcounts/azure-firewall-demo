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
  name     = "rg-agw-${local.instance_id}"
  location = "centralus"
  tags     = local.tags
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-${local.instance_id}"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  tags                       = local.tags

  // access_policy {
  //   tenant_id = data.azurerm_client_config.current.tenant_id
  //   object_id = data.azurerm_client_config.current.object_id

  //   certificate_permissions = [
  //     "create",
  //     "delete",
  //     "deleteissuers",
  //     "get",
  //     "getissuers",
  //     "import",
  //     "list",
  //     "listissuers",
  //     "managecontacts",
  //     "manageissuers",
  //     "purge",
  //     "setissuers",
  //     "update",
  //   ]

  //   key_permissions = [
  //     "backup",
  //     "create",
  //     "decrypt",
  //     "delete",
  //     "encrypt",
  //     "get",
  //     "import",
  //     "list",
  //     "purge",
  //     "recover",
  //     "restore",
  //     "sign",
  //     "unwrapKey",
  //     "update",
  //     "verify",
  //     "wrapKey",
  //   ]

  //   secret_permissions = [
  //     "backup",
  //     "delete",
  //     "get",
  //     "list",
  //     "purge",
  //     "recover",
  //     "restore",
  //     "set",
  //   ]
  // }
}

resource "azurerm_key_vault_certificate" "example" {
  name         = "generated-cert"
  key_vault_id = azurerm_key_vault.example.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    //   lifetime_action {
    //     action {
    //       action_type = "AutoRenew"
    //     }

    //     trigger {
    //       days_before_expiry = 30
    //     }
    //   }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    //   x509_certificate_properties {
    //     # Server Authentication = 1.3.6.1.5.5.7.3.1
    //     # Client Authentication = 1.3.6.1.5.5.7.3.2
    //     extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

    //     key_usage = [
    //       "cRLSign",
    //       "dataEncipherment",
    //       "digitalSignature",
    //       "keyAgreement",
    //       "keyCertSign",
    //       "keyEncipherment",
    //     ]

    //     subject_alternative_names {
    //       dns_names = ["internal.contoso.com", "domain.hello.world"]
    //     }

    //     subject            = "CN=hello-world"
    //     validity_in_months = 12
    //   }
  }
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
    ApplicationGatewaySubnet = cidrsubnet(azurerm_virtual_network.net["hub"].address_space.0, 2, 0)
  }

  address_prefixes     = [each.value]
  name                 = each.key
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.net["hub"].name
}

module "test" {
  source = "../"

  providers = {
    azurerm     = azurerm
    azurerm.ops = azurerm
  }

  certificate_secret_id = azurerm_key_vault_certificate.example.secret_id
  backend_addresses     = ["192.168.0.1"]
  host_name             = "test.contoso.com"
  instance_id           = local.instance_id
  subnet_id             = azurerm_subnet.subnet["ApplicationGatewaySubnet"].id
  tags                  = local.tags

  resource_groups = {
    env = azurerm_resource_group.test
    ops = azurerm_resource_group.test
  }
}