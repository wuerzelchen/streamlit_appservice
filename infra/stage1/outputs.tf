#azuread app id output
output "appregistration_client_id" {
  value = azuread_application.appreg_frontend.client_id
}

#azure ad app api id output
output "appregistration_api_id" {
  value = azuread_application.appreg_api.client_id
}

#azure ad app api credentials output
output "appregistration_api_password" {
  value     = azuread_application_password.appreg_api_password.value
  sensitive = true
}

#azure container registry server output
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

#azure resource group name output
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
