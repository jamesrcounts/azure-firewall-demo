terraform {
  required_version = ">= 1"

  required_providers {
    // aws = {
    //   source  = "hashicorp/aws"
    //   version = "~> 3"
    // }
    // azuread = {
    //   source  = "hashicorp/azuread"
    //   version = "~> 1"
    // }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2"
    }
    // random = {
    //   source  = "hashicorp/random"
    //   version = "~> 3"
    // }
    // pkcs12 = {
    //   source  = "chilicat/pkcs12"
    //   version = "~> 0"
    // }
  }
}