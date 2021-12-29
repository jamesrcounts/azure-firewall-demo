output "ip_address" {
  description = "The Application Gateway public IP address."
  value       = azurerm_public_ip.pip.ip_address
}