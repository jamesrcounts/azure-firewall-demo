resource "azurerm_public_ip" "pip" {
  for_each            = toset(["afw", "bastion"])
  name                = "pip-${each.key}-${var.env_instance_id}"
  tags                = local.tags
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}