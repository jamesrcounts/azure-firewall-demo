locals {
  bootstrap_command = <<COMMAND
  echo ${base64encode(var.ca_certificate)} > c:\root.pem.base64 && powershell "Set-Content -Path c:\root.pem -Value ([Text.Encoding]::UTF8.GetString([convert]::FromBase64String((Get-Content -Path c:\root.pem.base64))))" && certutil -addstore root c:\root.pem
COMMAND
}

resource "azurerm_windows_virtual_machine" "worker" {
  name                = "vm-worker-${var.instance_id}"
  computer_name       = "WorkerVM"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    var.network_interface_id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h1-pro"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "bootstrap" {
  name                       = "bootstrap"
  virtual_machine_id         = azurerm_windows_virtual_machine.worker.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version = true
  tags                       = var.tags

  settings = jsonencode({
    commandToExecute = local.bootstrap_command
  })
}

resource "azurerm_firewall_policy_rule_collection_group" "worker_rules" {
  firewall_policy_id = var.firewall_policy_id
  name               = "afwp-worker-${var.instance_id}"
  priority           = 200

  // priority 256
  application_rule_collection {
    action   = "Deny"
    name     = "BlockPage"
    priority = 256

    rule {
      name             = "BlockAzureEvents"
      source_addresses = ["*"]
      terminate_tls    = true
      destination_urls = [
        "azure.microsoft.com/en-us/community/events",
        "azure.microsoft.com/en-us/community/events/*"
      ]

      protocols {
        port = 443
        type = "Https"
      }
    }
  }

  // priority 512
  application_rule_collection {
    action   = "Allow"
    name     = "AllowWeb"
    priority = 512

    rule {
      name             = "AllowAzure"
      source_addresses = ["*"]
      terminate_tls    = true
      destination_fqdns = [
        "*azure.com",
        "*microsoft.com"
      ]

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name             = "AllowNews"
      source_addresses = ["*"]
      terminate_tls    = true
      web_categories = [
        "business",
        "webbasedemail"
      ]

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name             = "AllowURL"
      source_addresses = ["*"]
      terminate_tls    = true

      destination_urls = [
        "www.nytimes.com/section/world",
        "www.nytimes.com/section/world/*",
        "www.nytimes.com/vi-assets/static-assets/*",
        "static01.nyt.com/images/*"
      ]

      protocols {
        port = 80
        type = "Http"
      }

      protocols {
        port = 443
        type = "Https"
      }
    }
  }

  // priority 1024
  application_rule_collection {
    name     = "GeneralWeb"
    priority = 1024
    action   = "Allow"

    rule {
      name             = "AllowSports"
      source_addresses = ["*"]
      terminate_tls    = true
      web_categories = [
        "Sports"
      ]

      protocols {
        port = 80
        type = "Http"
      }

      protocols {
        port = 443
        type = "Https"
      }
    }
  }
}