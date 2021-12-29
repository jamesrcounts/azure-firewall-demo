locals {
  base_range = "10.0.0.0/16"
}

resource "azurerm_virtual_network" "net" {
  for_each = {
    hub    = cidrsubnet(local.base_range, 2, 0)
    worker = cidrsubnet(local.base_range, 2, 2)
    server = cidrsubnet(local.base_range, 2, 3)
  }

  address_space       = [each.value]
  location            = var.resource_group.location
  name                = "vnet-${each.key}-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = toset(["worker", "server"])

  name                      = "hub-to-${each.key}"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.net["hub"].name
  remote_virtual_network_id = azurerm_virtual_network.net[each.value].id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = toset(["worker", "server"])

  name                      = "${each.key}-to-hub"
  resource_group_name       = var.resource_group.name
  virtual_network_name      = azurerm_virtual_network.net[each.value].name
  remote_virtual_network_id = azurerm_virtual_network.net["hub"].id
}

resource "azurerm_subnet" "hub_subnet" {
  for_each = {
    AzureBastionSubnet       = 0
    AzureFirewallSubnet      = 1
    ApplicationGatewaySubnet = 2
  }

  address_prefixes     = [cidrsubnet(azurerm_virtual_network.net["hub"].address_space.0, 2, each.value)]
  name                 = each.key
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.net["hub"].name
}

resource "azurerm_subnet" "server_subnet" {
  for_each = {
    ServerSubnet = 3
  }

  address_prefixes     = [cidrsubnet(azurerm_virtual_network.net["server"].address_space.0, 2, each.value)]
  name                 = each.key
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.net["server"].name
}

resource "azurerm_subnet" "worker_subnet" {
  for_each = {
    WorkerSubnet = 3
  }

  address_prefixes     = [cidrsubnet(azurerm_virtual_network.net["worker"].address_space.0, 2, each.value)]
  name                 = each.key
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.net["worker"].name
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "https" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  direction                   = "Inbound"
  name                        = "HTTPS"
  network_security_group_name = azurerm_network_security_group.web.name
  priority                    = 2048
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_address_prefixes     = azurerm_subnet.hub_subnet["ApplicationGatewaySubnet"].address_prefixes
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "default_deny_in" {
  access                      = "Deny"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "default-deny-in"
  network_security_group_name = azurerm_network_security_group.web.name
  priority                    = 4096
  protocol                    = "*"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "internet_out" {
  access                      = "Allow"
  destination_address_prefix  = "Internet"
  destination_port_range      = "*"
  direction                   = "Outbound"
  name                        = "internet-out"
  network_security_group_name = azurerm_network_security_group.web.name
  priority                    = 2048
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "agw_out" {
  access                       = "Allow"
  destination_address_prefixes = azurerm_subnet.hub_subnet["ApplicationGatewaySubnet"].address_prefixes
  destination_port_range       = "*"
  direction                    = "Outbound"
  name                         = "agw-out"
  network_security_group_name  = azurerm_network_security_group.web.name
  priority                     = 2049
  protocol                     = "Tcp"
  resource_group_name          = var.resource_group.name
  source_address_prefix        = "*"
  source_port_range            = "*"
}

resource "azurerm_network_security_rule" "default_deny_out" {
  access                      = "Deny"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "*"
  direction                   = "Outbound"
  name                        = "default-deny-out"
  network_security_group_name = azurerm_network_security_group.web.name
  priority                    = 4096
  protocol                    = "*"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_interface" "server" {
  location            = var.resource_group.location
  name                = "nic-server-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags

  ip_configuration {
    name                          = "ServerIPConfiguration"
    private_ip_address_allocation = "dynamic"
    subnet_id                     = azurerm_subnet.server_subnet["ServerSubnet"].id
  }
}

resource "azurerm_network_interface" "worker" {
  location            = var.resource_group.location
  name                = "nic-worker-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags

  ip_configuration {
    name                          = "WorkerIPConfiguration"
    private_ip_address            = "10.0.10.10"
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.worker_subnet["WorkerSubnet"].id
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_to_server" {
  network_security_group_id = azurerm_network_security_group.web.id
  subnet_id                 = azurerm_subnet.server_subnet["ServerSubnet"].id
}

resource "azurerm_route_table" "rt" {
  for_each = toset([
    "agw",
    "server",
  ])

  disable_bgp_route_propagation = true
  location                      = var.resource_group.location
  name                          = "rt-${each.key}-${var.instance_id}"
  resource_group_name           = var.resource_group.name
  tags                          = var.tags
}

resource "azurerm_subnet_route_table_association" "rta" {
  for_each = {
    agw    = azurerm_subnet.hub_subnet["ApplicationGatewaySubnet"].id
    server = azurerm_subnet.server_subnet["ServerSubnet"].id
  }

  route_table_id = azurerm_route_table.rt[each.key].id
  subnet_id      = each.value
}

data "azurerm_network_watcher" "nw" {
  name                = "NetworkWatcher_${var.resource_group.location}"
  resource_group_name = "NetworkWatcherRG"
}

resource "azurerm_network_watcher_flow_log" "web_network_logs" {
  enabled                   = true
  network_security_group_id = azurerm_network_security_group.web.id
  network_watcher_name      = data.azurerm_network_watcher.nw.name
  resource_group_name       = "NetworkWatcherRG"
  storage_account_id        = var.log_storage_account_id
  version                   = 2
  tags                      = var.tags

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    interval_in_minutes   = 10
    workspace_id          = var.log_analytics_workspace.workspace_id
    workspace_region      = var.log_analytics_workspace.location
    workspace_resource_id = var.log_analytics_workspace.id
  }
}