#resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.projectname}-${random_id.suffix.hex}"
  location = local.region
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}
