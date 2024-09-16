#azurerm provider
provider "azurerm" {
  features {}
}

provider "azuread" {

}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "samplestaccwolflad"
    container_name       = "tfstate"
    key                  = "aadstreamlit-stage1.tfstate"
  }
}
