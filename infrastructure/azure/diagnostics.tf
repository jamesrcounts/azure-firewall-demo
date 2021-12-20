module "diagnostics" {
  source = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=diagnostics-0.0.1"

  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id

  monitored_services = {
    bastion = azurerm_bastion_host.bh.id
    fw      = azurerm_firewall.fw.id
    kv      = azurerm_key_vault.afw.id
    nic     = azurerm_network_interface.worker.id
    pipfw   = azurerm_public_ip.pip["afw"].id
    piphb   = azurerm_public_ip.pip["bastion"].id
    vnet    = azurerm_virtual_network.net.id
    agw=azurerm_application_gateway.agw.id
  }
}