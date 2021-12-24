output "private_ip_address" {
  description = "The firewall's private IP."
  value = azurerm_firewall.fw.ip_configuration.0.private_ip_address
}