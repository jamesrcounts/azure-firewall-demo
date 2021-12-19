// A dedicated key vault for the firewall, uses access policies due to apparent 
// limitation in firewall.
// TODO: This may be a portal UI issue...test again now that you have the right
// cert
resource "azurerm_key_vault" "afw" {
  depends_on = [
    azurerm_user_assigned_identity.afwp
  ]

  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  location                        = data.azurerm_resource_group.rg.location
  name                            = "kv-afw-${var.env_instance_id}"
  resource_group_name             = data.azurerm_resource_group.rg.name
  sku_name                        = "standard"
  soft_delete_retention_days      = 7
  tags                            = local.tags
  tenant_id                       = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "afw_access" {
  key_vault_id = azurerm_key_vault.afw.id
  object_id    = azurerm_user_assigned_identity.afwp.principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "management_access" {
  key_vault_id = azurerm_key_vault.afw.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

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
    "Set",
  ]
}

resource "azurerm_key_vault_certificate" "ca_cert" {
  depends_on = [
    azurerm_key_vault_access_policy.management_access
  ]

  key_vault_id = azurerm_key_vault.afw.id
  name         = "CACert"

  certificate {
    contents = filebase64("${path.module}/certs/interCA.pfx")
    password = ""
  }
}