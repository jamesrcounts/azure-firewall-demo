resource "azurerm_network_interface" "worker" {
  location            = data.azurerm_resource_group.rg.location
  name                = "nic-worker-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "WorkerIPConfiguration"
    private_ip_address            = "10.0.10.10"
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.subnet["WorkerSubnet"].id
  }
}

resource "azurerm_windows_virtual_machine" "worker" {
  name                = "vm-worker-${var.env_instance_id}"
  computer_name       = "WorkerVM"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.worker.id,
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

locals {
  bootstrap_command = <<COMMAND
  echo '${filebase64("${path.module}/certs/rootCA.crt")}' > c:\\root.pem.base64 && powershell \"Set-Content -Path c:\\root.pem -Value ([Text.Encoding]::UTF8.GetString([convert]::FromBase64String((Get-Content -Path c:\\root.pem.base64))))\" && certutil -addstore root c:\\root.pem
COMMAND
}

resource "azurerm_virtual_machine_extension" "bootstrap" {
  name                       = "bootstrap"
  virtual_machine_id         = azurerm_windows_virtual_machine.worker.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version = true
  tags                       = local.tags

  settings = jsonencode({
    commandToExecute = local.bootstrap_command
  })
}
