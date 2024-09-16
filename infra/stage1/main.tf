#resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.projectname}-${random_id.suffix.hex}"
  location = local.region
  tags     = var.tags
}

data "http" "myip" {
  #url = "https://ipv4.icanhazip.com"
  url = "https://api.ipify.org?format=raw"
}
