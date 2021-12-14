locals {
  tags = data.azurerm_resource_group.rg.tags
}

# Read details about the resource group created for this project.
data "azurerm_resource_group" "rg" {
  name = "rg-${var.env_instance_id}"
}

data "azurerm_resource_group" "ops" {
  provider = azurerm.ops

  name = "rg-backend-${var.ops_instance_id}"
}

# Assign roles for resources in the resource group.
resource "azurerm_role_assignment" "keyvault_secrets_user" {
  principal_id = azurerm_user_assigned_identity.afwp.principal_id
  // role_definition_name = "Key Vault Secrets User"
  role_definition_name = "Key Vault Administrator"
  scope                = data.azurerm_resource_group.ops.id
}