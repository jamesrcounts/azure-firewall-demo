locals {
  agw_name                       = "agw-${var.instance_id}"
  frontend_ip_configuration_name = "public"
  backend_address_pool_name      = "private"
  ssl_certificate_name           = "ssl"
}

resource "azurerm_user_assigned_identity" "agw" {
  location            = var.resource_groups["env"].location
  name                = "uai-${local.agw_name}"
  resource_group_name = var.resource_groups["env"].name
  tags                = var.tags
}

resource "azurerm_role_assignment" "keyvault_secrets_user" {
  provider = azurerm.ops

  scope                = var.resource_groups["ops"].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.agw.principal_id
}

resource "azurerm_public_ip" "pip" {
  allocation_method   = "Static"
  location            = var.resource_groups["env"].location
  name                = "pip-${local.agw_name}"
  resource_group_name = var.resource_groups["env"].name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "agw" {
  depends_on = [
    azurerm_role_assignment.keyvault_secrets_user
  ]

  location            = var.resource_groups["env"].location
  name                = local.agw_name
  resource_group_name = var.resource_groups["env"].name
  tags                = var.tags
  zones               = [1, 2, 3]

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 3
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.backend_addresses
  }

  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = "https"
    path                  = "/"
    port                  = 443
    probe_name            = "https"
    protocol              = "Https"
    request_timeout       = 180
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_port {
    name = "http"
    port = 80
  }

  gateway_ip_configuration {
    name      = "public"
    subnet_id = var.subnet_id
  }

  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "https"
    host_name                      = var.host_name
    name                           = "https"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = local.ssl_certificate_name
  }

  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "http"
    host_name                      = var.host_name
    name                           = "http"
    protocol                       = "Http"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }

  probe {
    host                = var.host_name
    interval            = 30
    name                = "https"
    path                = "/"
    protocol            = "Https"
    timeout             = 1
    unhealthy_threshold = 3
  }

  request_routing_rule {
    name                       = "https"
    rule_type                  = "Basic"
    http_listener_name         = "https"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = "https"
  }

  request_routing_rule {
    name                        = "http"
    rule_type                   = "Basic"
    http_listener_name          = "http"
    redirect_configuration_name = "http-to-https"
  }

  redirect_configuration {
    name                 = "http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "https"
  }

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  ssl_certificate {
    name                = local.ssl_certificate_name
    key_vault_secret_id = var.certificate_secret_id
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  trusted_root_certificate {
    name = "RootCA"
    data = base64encode(var.ca_certificate)
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"
  }
}

module "diagnostics" {
  source = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=diagnostics-0.0.1"

  log_analytics_workspace_id = var.log_analytics_workspace_id

  monitored_services = {
    pip = azurerm_public_ip.pip.id
    agw = azurerm_application_gateway.agw.id
  }
}