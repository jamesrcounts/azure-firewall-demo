locals {
  agw_name                       = "agw-${local.environment_id}"
  environment_id                 = var.env_instance_id
  frontend_ip_configuration_name = "public"
  backend_address_pool_name      = "private"
  ssl_certificate_name           = "ssl"
}

resource "azurerm_user_assigned_identity" "agw" {
  location            = data.azurerm_resource_group.rg.location
  name                = "uai-${local.agw_name}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = data.azurerm_resource_group.rg.tags
}

resource "azurerm_role_assignment" "keyvault_secrets_user" {
  provider = azurerm.ops

  scope                = data.azurerm_resource_group.ops.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.agw.principal_id
}

resource "azurerm_application_gateway" "agw" {
  depends_on = [
    azurerm_role_assignment.keyvault_secrets_user
  ]

  location            = data.azurerm_resource_group.rg.location
  name                = local.agw_name
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = data.azurerm_resource_group.rg.tags
  zones               = [1, 2, 3]

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 3
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [azurerm_network_interface.server.private_ip_address]
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
    public_ip_address_id = azurerm_public_ip.pip["agw"].id
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
    subnet_id = azurerm_subnet.subnet["ApplicationGatewaySubnet"].id
  }

  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "https"
    host_name                      = local.hostname_server
    name                           = "https"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = local.ssl_certificate_name
  }

  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "http"
    host_name                      = local.hostname_server
    name                           = "http"
    protocol                       = "Http"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }

  probe {
    host                = local.hostname_server
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
    key_vault_secret_id = data.azurerm_key_vault_secret.certificate["pfx"].id
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"
  }
}

resource "azurerm_route_table" "agw" {
  disable_bgp_route_propagation = false
  location                      = data.azurerm_resource_group.rg.location
  name                          = "rt-agw-${var.env_instance_id}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  tags                          = local.tags
}

resource "azurerm_route" "server_thru_firewall" {
  address_prefix         = azurerm_subnet.subnet["ServerSubnet"].address_prefix
  name                   = "ServerThruFirewall"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration.0.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.agw.name
}

// resource "azurerm_subnet_route_table_association" "server_thru_firewall" {
//   for_each = toset(["ServerSubnet"])

//   route_table_id = azurerm_route_table.agw.id
//   subnet_id      = azurerm_subnet.subnet[each.key].id
// }