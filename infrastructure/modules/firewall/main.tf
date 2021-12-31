resource "azurerm_user_assigned_identity" "afwp" {
  location            = var.resource_group.location
  name                = "uai-afwp-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "keyvault_certificate_officer" {
  scope                = var.resource_group.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = azurerm_user_assigned_identity.afwp.principal_id
}

resource "azurerm_role_assignment" "keyvault_secret_user" {
  scope                = var.resource_group.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.afwp.principal_id
}

resource "azurerm_firewall_policy" "afwp" {
  depends_on = [
    azurerm_role_assignment.keyvault_certificate_officer,
    azurerm_role_assignment.keyvault_secret_user
  ]

  location            = var.resource_group.location
  name                = "afwp-${var.instance_id}"
  resource_group_name = var.resource_group.name
  sku                 = "Premium"
  tags                = var.tags

  identity {
    type                       = "UserAssigned"
    user_assigned_identity_ids = [azurerm_user_assigned_identity.afwp.id]
  }

  intrusion_detection {
    mode = "Alert"
    signature_overrides {
      id    = "2024897"
      state = "Deny"
    }
    signature_overrides {
      id    = "2024898"
      state = "Alert"
    }

    traffic_bypass {
      destination_addresses = ["1.1.1.1"]
      destination_ports     = ["80"]
      name                  = "SecretBypass"
      protocol              = "TCP"
      source_addresses      = ["*"]
    }
  }

  tls_certificate {
    key_vault_secret_id = var.ca_secret_id
    name                = "CACert"
  }
}



resource "azurerm_public_ip" "pip" {
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "pip-afw-${var.instance_id}"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "fw" {
  firewall_policy_id  = azurerm_firewall_policy.afwp.id
  location            = var.resource_group.location
  name                = "fw-${var.instance_id}"
  resource_group_name = var.resource_group.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  tags                = var.tags

  ip_configuration {
    name                 = "FirewallIPConfiguration"
    public_ip_address_id = azurerm_public_ip.pip.id
    subnet_id            = var.subnet_id
  }
}

module "diagnostics" {
  source = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=diagnostics-0.0.2"

  log_analytics_workspace_id = var.log_analytics_workspace_id

  monitored_services = {
    fw    = azurerm_firewall.fw.id
    pip = azurerm_public_ip.pip.id
  }
}