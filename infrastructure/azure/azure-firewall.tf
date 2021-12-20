resource "azurerm_firewall" "fw" {
  firewall_policy_id  = azurerm_firewall_policy.afwp.id
  location            = data.azurerm_resource_group.rg.location
  name                = "fw-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  tags                = local.tags

  ip_configuration {
    name                 = "FirewallIPConfiguration"
    public_ip_address_id = azurerm_public_ip.pip["afw"].id
    subnet_id            = azurerm_subnet.subnet["AzureFirewallSubnet"].id
  }
}