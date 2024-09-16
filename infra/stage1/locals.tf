#local variables
locals {
  region      = "francecentral"
  projectname = "slentra"
  random_uuid = random_uuid.rand.id
}

#random suffix
resource "random_id" "suffix" {
  byte_length = 4
}

#client config
data "azurerm_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "ossrdbms" {
  client_id = data.azuread_application_published_app_ids.well_known.result["OssRdbms"]
}

resource "random_uuid" "rand" {}
