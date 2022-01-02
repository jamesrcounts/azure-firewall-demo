output "public_ip_address" {
  description = "The firewall's public IP."
  value       = azurerm_public_ip.pip.ip_address
}

output "private_ip_address" {
  description = "The firewall's private IP."
  value       = azurerm_firewall.fw.ip_configuration.0.private_ip_address
}

output "firewall_policy_id" {
  description = "The firewall's policy ID."
  value       = azurerm_firewall_policy.afwp.id
}