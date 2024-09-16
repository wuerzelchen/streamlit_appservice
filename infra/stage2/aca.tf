# azure container app resource
resource "azurerm_container_app" "aca" {
  name                         = "aca-${local.projectname}-${random_id.suffix.hex}"
  resource_group_name          = data.azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.acae.id
  revision_mode                = "Single"

  template {
    container {
      name   = "slentra"
      image  = "${data.azurerm_container_registry.acr.login_server}/slentra:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

# azure container app environment
resource "azurerm_container_app_environment" "acae" {
  name                = "acae-${local.projectname}-${random_id.suffix.hex}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
}

# role binding, assigns the managed identity of the app service to the acr with acr pull rights
resource "azurerm_role_assignment" "aca_acr_role" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.aca.identity[0].principal_id
}

# role binding, for the entity who executes this terraform script
resource "azurerm_role_assignment" "aca_acr_role_current" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_client_config.current.object_id
}
