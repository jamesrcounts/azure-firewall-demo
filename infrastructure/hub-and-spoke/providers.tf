provider "azurerm" {
  subscription_id = var.env_subscription_id

  features {}
}

provider "azurerm" {
  alias = "ops"

  features {}
}
