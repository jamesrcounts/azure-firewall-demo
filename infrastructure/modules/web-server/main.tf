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

resource "azurerm_network_interface" "server" {
  location            = var.resource_group.location
  name                = "nic-server-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags

  ip_configuration {
    name                          = "ServerIPConfiguration"
    private_ip_address_allocation = "dynamic"
    subnet_id                     = var.subnet.id
  }
}

resource "azurerm_private_dns_a_record" "server" {
  name                = "firewall"
  zone_name           = var.zone_name
  resource_group_name = var.resource_group.name
  ttl                 = 300
  records             = [azurerm_network_interface.server.private_ip_address]
  tags=var.tags
}

resource "azurerm_linux_virtual_machine" "server" {
  depends_on=[
    azurerm_firewall_policy_rule_collection_group.server_rules
  ]
  
  admin_password                  = "Password1234!"
  admin_username                  = "plankton"
  computer_name                   = "ServerVM"
  custom_data                     = base64encode(local.user_data)
  disable_password_authentication = false
  location                        = var.resource_group.location
  name                            = "vm-server-${var.instance_id}"
  network_interface_ids           = [azurerm_network_interface.server.id]
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

resource "azurerm_firewall_policy_rule_collection_group" "server_rules" {
  firewall_policy_id = var.firewall_policy_id
  name               = "afwp-server-${var.instance_id}"
  priority           = 500

  // network_rule_collection {
  //   action   = "Allow"
  //   name     = "AgwToServer"
  //   priority = 400

  //   rule {
  //     name                  = "AllowWebServer"
  //     protocols             = ["TCP", "UDP"]
  //     source_addresses      = var.allowed_source_addresses
  //     destination_addresses = [var.subnet.address_prefix]
  //     destination_ports     = ["443"]
  //   }
  // }

  // priority 512
  application_rule_collection {
    action   = "Allow"
    name     = "AllowWeb"
    priority = 512

    rule {
      name             = "AllowOSUpdates"
      source_addresses = ["*"]
      destination_fqdns = [
        "api.snapcraft.io",
        "azure.archive.ubuntu.com",
        "changelogs.ubuntu.com",
        "download.opensuse.org",
        "motd.ubuntu.com",
        "packages.microsoft.com",
        "security.ubuntu.com",
        "snapcraft.io",
      ]

      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  # TODO: works, next test whether AGW needs to be an allowed source in firewall/nsg
  application_rule_collection {
    action   = "Allow"
    name     = "AgwToServer"
    priority = 129

    rule {
      name             = "AllowWebServer"
      source_addresses = var.allowed_source_addresses
      terminate_tls    = true

      destination_fqdns = [
        "firewall.jamesrcounts.com"
      ]

      protocols {
        port = 443
        type = "Https"
      }
    }
  }
}