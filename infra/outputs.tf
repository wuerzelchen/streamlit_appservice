# database endpoint output
output "database_endpoint" {
  value = azurerm_postgresql_flexible_server.pg.fqdn
}

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
