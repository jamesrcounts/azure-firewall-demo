# Create the Linux App Service Plan
resource "azurerm_app_service_plan" "appserviceplan" {
  location            = data.azurerm_resource_group.rg.location
  name                = "asp-webapp-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  sku {
    tier = "Free"
    size = "F1"
  }
}
# Create the web app, pass in the App Service Plan ID, and deploy code from a public GitHub repo
resource "azurerm_app_service" "webapp" {
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
  location            = data.azurerm_resource_group.rg.location
  name                = "as-webapp-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  source_control {
    repo_url           = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}