resource "azurerm_public_ip" "pip" {
  for_each = toset(["afw", "bastion", "srvr", "agw"])

  allocation_method   = "Static"
  location            = data.azurerm_resource_group.rg.location
  name                = "pip-${each.key}-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = local.tags
}