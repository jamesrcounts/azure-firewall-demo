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
    key_vault_secret_id = azurerm_key_vault_certificate.ca_cert.secret_id
    name                = "CACert"
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "rules" {
  firewall_policy_id = azurerm_firewall_policy.afwp.id
  name               = "afwp-rcg-${var.env_instance_id}"
  priority           = 200
 
  application_rule_collection {
    name     = "GeneralWeb"
    priority = 1024
    action   = "Allow"

    rule {
      name             = "AllowSports"
      source_addresses = ["*"]
      terminate_tls    = true
      web_categories = [
        "Sports"
      ]

      protocols {
        port = 80
        type = "Http"
      }

      protocols {
        port = 443
        type = "Https"
      }
    }
  }

  application_rule_collection {
    action   = "Allow"
    name     = "AllowWeb"
    priority = 512

    rule {
      name             = "AllowAzure"
      source_addresses = ["*"]
      terminate_tls    = true
      destination_fqdns = [
        "*azure.com",
        "*microsoft.com"
      ]

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name             = "AllowNews"
      source_addresses = ["*"]
      terminate_tls    = true
      web_categories = [
        "business",
        "webbasedemail"
      ]

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name             = "AllowAppService"
      source_addresses = ["*"]
      terminate_tls    = true

      destination_fqdns = [
        azurerm_app_service.webapp.default_site_hostname
      ]

      protocols {
        port = 80
        type = "Http"
      }

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name             = "AllowURL"
      source_addresses = ["*"]
      terminate_tls    = true

      destination_urls = [
        "www.nytimes.com/section/world",
        "www.nytimes.com/section/world/*",
        "www.nytimes.com/vi-assets/static-assets/*",
        "static01.nyt.com/images/*"
      ]

      protocols {
        port = 80
        type = "Http"
      }

      protocols {
        port = 443
        type = "Https"
      }
    }
  }

  application_rule_collection {
    action   = "Deny"
    name     = "BlockPage"
    priority = 256

    rule {
      name             = "BlockAzureEvents"
      source_addresses = ["*"]
      terminate_tls    = true
      destination_urls = [
        "azure.microsoft.com/en-us/community/events",
        "azure.microsoft.com/en-us/community/events/*"
      ]

      protocols {
        port = 443
        type = "Https"
      }
    }
  }
}
