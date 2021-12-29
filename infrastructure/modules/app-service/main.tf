# Create the Linux App Service Plan
resource "azurerm_app_service_plan" "appserviceplan" {
  location            = var.resource_group.location
  name                = "asp-webapp-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags

  sku {
    tier = "Free"
    size = "F1"
  }
}

# Create the web app, pass in the App Service Plan ID, and deploy code from a public GitHub repo
resource "azurerm_app_service" "webapp" {
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
  location            = var.resource_group.location
  name                = "as-webapp-${var.instance_id}"
  resource_group_name = var.resource_group.name
  tags                = var.tags

  source_control {
    repo_url           = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}

module "diagnostics" {
  source = "github.com/jamesrcounts/terraform-modules.git//diagnostics?ref=diagnostics-0.0.1"

  log_analytics_workspace_id = var.log_analytics_workspace_id

  monitored_services = {
    app = azurerm_app_service.webapp.id
  }
}