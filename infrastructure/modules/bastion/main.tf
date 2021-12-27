resource "azurerm_public_ip" "pip" {
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "pip-bastion-${var.instance_id}"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bh" {
  location            = var.resource_group.location
  name                = "abh-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags

  ip_configuration {
    name                 = "BastionIpConfiguration"
    public_ip_address_id = azurerm_public_ip.pip.id
    subnet_id            = var.subnet_id
  }
}

module "diagnostics" {
  source = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=diagnostics-0.0.1"

  log_analytics_workspace_id = var.log_analytics_workspace_id

  monitored_services = {
    bh  = azurerm_bastion_host.bh.id
    pip = azurerm_public_ip.pip.id
  }
}