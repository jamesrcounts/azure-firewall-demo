resource "azurerm_virtual_network" "net" {
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  name                = "vnet-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    AzureBastionSubnet       = ["10.0.20.0/24"]
    AzureFirewallSubnet      = ["10.0.100.0/24"]
    WorkerSubnet             = ["10.0.10.0/24"]
    ServerSubnet             = ["10.0.40.0/24"]
    ApplicationGatewaySubnet = ["10.0.50.0/24"]
  }

  address_prefixes     = each.value
  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.net.name
}
