terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.115"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.2"
    }
  }
}

provider "azurerm" {
  features {}
}