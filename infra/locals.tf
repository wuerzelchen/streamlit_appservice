#local variables
locals {
  region      = "francecentral"
  projectname = "slentra"
}

#random suffix
resource "random_id" "suffix" {
  byte_length = 4
}

#client config
data "azurerm_client_config" "current" {}
