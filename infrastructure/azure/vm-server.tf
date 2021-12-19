resource "azurerm_public_ip" "server" {
  allocation_method   = "Static"
  location            = data.azurerm_resource_group.rg.location
  name                = "pip-server-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "server" {
  location            = data.azurerm_resource_group.rg.location
  name                = "nic-server-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "ServerIPConfiguration"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.server.id
    subnet_id                     = azurerm_subnet.subnet["ServerSubnet"].id
  }
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "http" {
  name                        = "HTTP"
  priority                    = 1024
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  priority                    = 2048
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
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

// todo dns