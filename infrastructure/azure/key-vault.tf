// A dedicated key vault for the firewall, uses access policies due to apparent limitation in firewall.
resource "azurerm_key_vault" "afw" {
  depends_on = [
    azurerm_user_assigned_identity.afwp
  ]

  name                            = "kv-afw-${var.env_instance_id}"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  soft_delete_retention_days      = 7
  tags                            = local.tags
}

resource "azurerm_key_vault_access_policy" "afw_access" {
  key_vault_id = azurerm_key_vault.afw.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.afwp.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "management_access" {
  key_vault_id = azurerm_key_vault.afw.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "setissuers",
    "update",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
}

resource "azurerm_key_vault_certificate" "ca_cert" {
  name         = "CACert"
  key_vault_id = azurerm_key_vault.afw.id

  certificate {
    contents = filebase64("${path.module}/certs/interCA.pfx")
    password = ""
  }
}
