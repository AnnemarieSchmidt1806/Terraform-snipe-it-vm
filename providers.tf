terraform {
  required_version = ">=1.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.115"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
 