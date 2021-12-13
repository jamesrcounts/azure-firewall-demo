# Read details about the resource group created for this project.
data "azurerm_resource_group" "rg" {
  name = "rg-${var.env_instance_id}"
}