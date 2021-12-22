locals {
  user_data = templatefile(
    "${path.module}/templates/server-setup.init.tftpl",
    {
      nginx_site_conf = filebase64("${path.module}/templates/nginx-site.conf")
      ssl_cert_b64    = base64encode(var.certificate.cert_pem)
      ssl_key_b64     = base64encode(var.certificate.private_key_pem)
    }
  )
}

resource "azurerm_linux_virtual_machine" "server" {
  admin_password                  = "Password1234!"
  admin_username                  = "plankton"
  computer_name                   = "ServerVM"
  custom_data                     = base64encode(local.user_data)
  disable_password_authentication = false
  location                        = var.resource_group.location
  name                            = "vm-server-${var.instance_id}"
  network_interface_ids           = [var.network_interface_id]
  resource_group_name             = var.resource_group.name
  size                            = "Standard_B2s"
  tags                            = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    name                 = "os-vm-server-${var.instance_id}"
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
  location                      = var.resource_group.location
  name                          = "rt-server-${var.instance_id}"
  resource_group_name           = var.resource_group.name
  tags                          = var.tags
}

// resource "azurerm_route" "agw_thru_firewall" {
//   address_prefix         = azurerm_subnet.subnet["ApplicationGatewaySubnet"].address_prefix
//   name                   = "AgwThruFirewall"
//   next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration.0.private_ip_address
//   next_hop_type          = "VirtualAppliance"
//   resource_group_name    = var.resource_group.name
//   route_table_name       = azurerm_route_table.server.name
// }

// resource "azurerm_subnet_route_table_association" "agw_thru_firewall" {
//   for_each = toset(["ServerSubnet"])

//   route_table_id = azurerm_route_table.server.id
//   subnet_id      = azurerm_subnet.subnet[each.key].id
// }