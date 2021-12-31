provider "azurerm" {
  subscription_id = var.env_subscription_id

  features {}
}

provider "azurerm" {
  alias = "ops"

  features {}
}

// provider "aws" {
//   region = "us-west-2"
// }