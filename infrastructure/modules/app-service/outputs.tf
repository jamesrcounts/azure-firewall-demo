output "default_site_hostname" {
  description = "The default hostname for the app service."
  value       = azurerm_app_service.webapp.default_site_hostname
}