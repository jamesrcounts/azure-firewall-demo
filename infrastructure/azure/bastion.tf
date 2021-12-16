resource "azurerm_bastion_host" "bh" {
  location            = data.azurerm_resource_group.rg.location
  name                = "abh-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                 = "BastionIpConfiguration"
    public_ip_address_id = azurerm_public_ip.pip["bastion"].id
    subnet_id            = azurerm_subnet.subnet["AzureBastionSubnet"].id
  }
}