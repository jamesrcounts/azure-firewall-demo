resource "azurerm_user_assigned_identity" "afwp" {
  location            = data.azurerm_resource_group.rg.location
  name                = "uai-afwp-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_firewall_policy" "afwp" {
  location            = data.azurerm_resource_group.rg.location
  name                = "afwp-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Premium"
  tags                = local.tags

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
    name                = "CACert"
    key_vault_secret_id = azurerm_key_vault_certificate.ca_cert.secret_id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "rules" {
  name               = "afwp-rcg-${var.env_instance_id}"
  firewall_policy_id = azurerm_firewall_policy.afwp.id
  priority           = 200

  application_rule_collection {
    name     = "AllowWeb"
    priority = 101
    action   = "Allow"

    rule {
      name             = "AllowAzure"
      terminate_tls    = true
      source_addresses = ["*"]
      destination_fqdns = [
        "*azure.com",
        "*microsoft.com"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "AllowNews"
      terminate_tls    = true
      source_addresses = ["*"]
      web_categories = [
        "business",
        "webbasedemail"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  application_rule_collection {
    name     = "BlockPage"
    priority = 100
    action   = "Deny"

    rule {
      name             = "BlockAzureEvents"
      terminate_tls    = true
      source_addresses = ["*"]
      destination_urls = [
        "azure.microsoft.com/en-us/community/events",
        "azure.microsoft.com/en-us/community/events/*"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}
