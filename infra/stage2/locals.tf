#local variables
locals {
  region                  = "francecentral"
  projectname             = "slentra"
  resource_group_name     = var.resource_group_name
  container_registry_name = var.container_registry_name
}

#random suffix
resource "random_id" "suffix" {
  byte_length = 4
}

#client config
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

data "azurerm_container_registry" "acr" {
  name                = local.container_registry_name
  resource_group_name = data.azurerm_resource_group.rg.name
}
