terraform {
  required_version = ">= 1"

  backend "remote" {}

  required_providers {
    // aws = {
    //   source  = "hashicorp/aws"
    //   version = "~> 3"
    // }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2"
    }
  }
}