resource "azurerm_network_interface" "server" {
  location            = data.azurerm_resource_group.rg.location
  name                = "nic-server-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "ServerIPConfiguration"
    private_ip_address_allocation = "dynamic"
    subnet_id                     = azurerm_subnet.subnet["ServerSubnet"].id
  }
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  priority                    = 2048
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = azurerm_subnet.subnet["ApplicationGatewaySubnet"].address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_rule" "default_deny_in" {
  name                        = "default-deny-in"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_rule" "default_deny_out" {
  name                        = "default-deny-out"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_interface_security_group_association" "nsg_to_nic" {
  network_interface_id      = azurerm_network_interface.server.id
  network_security_group_id = azurerm_network_security_group.web.id
}

locals {
  user_data = templatefile(
    "${path.module}/scripts/server-setup.init.tftpl",
    {
      nginx_site_conf = filebase64("${path.module}/scripts/nginx-site.conf")
      ssl_cert_b64    = base64encode(data.azurerm_key_vault_secret.certificate["crt"].value)
      ssl_key_b64     = base64encode(data.azurerm_key_vault_secret.certificate["key"].value)
    }
  )
}

resource "azurerm_linux_virtual_machine" "server" {
  admin_password                  = "Password1234!"
  admin_username                  = "plankton"
  computer_name                   = "ServerVM"
  custom_data                     = base64encode(local.user_data)
  disable_password_authentication = false
  location                        = data.azurerm_resource_group.rg.location
  name                            = "vm-server-${var.env_instance_id}"
  network_interface_ids           = [azurerm_network_interface.server.id]
  resource_group_name             = data.azurerm_resource_group.rg.name
  size                            = "Standard_B2s"
  tags                            = local.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    name                 = "os-vm-server-${var.env_instance_id}"
  }

  source_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }
}

resource "azurerm_route_table" "server" {
  disable_bgp_route_propagation = false
  location                      = data.azurerm_resource_group.rg.location
  name                          = "rt-server-${var.env_instance_id}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  tags                          = local.tags
}

resource "azurerm_route" "agw_thru_firewall" {
  address_prefix         = azurerm_subnet.subnet["ApplicationGatewaySubnet"].address_prefix
  name                   = "AgwThruFirewall"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration.0.private_ip_address
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.server.name
}

// resource "azurerm_subnet_route_table_association" "agw_thru_firewall" {
//   for_each = toset(["ServerSubnet"])

//   route_table_id = azurerm_route_table.server.id
//   subnet_id      = azurerm_subnet.subnet[each.key].id
// }