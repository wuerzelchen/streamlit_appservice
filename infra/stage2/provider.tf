#azurerm provider
provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "samplestaccwolflad"
    container_name       = "tfstate"
    key                  = "aadstreamlit-stage2.tfstate"
  }
}
