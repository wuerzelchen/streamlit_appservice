resource "azuread_application" "appreg_frontend" {
  # The display name of the application with locals joined
  display_name                   = "appreg-frontend-${local.projectname}-${random_id.suffix.hex}"
  identifier_uris                = ["api://frontend-${local.projectname}-${random_id.suffix.hex}"]
  owners                         = [data.azurerm_client_config.current.object_id]
  sign_in_audience               = "AzureADMyOrg"
  fallback_public_client_enabled = true

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
  }

  feature_tags {
    enterprise = true
    gallery    = true
  }

  single_page_application {
    redirect_uris = ["http://localhost:5005/", "https://slentra.livelyhill-6cbc2781.francecentral.azurecontainerapps.io/"]
  }

  lifecycle {
    ignore_changes = [
      api[0].oauth2_permission_scope,
      required_resource_access
    ]
  }
}

resource "azuread_application_api_access" "create_person_access_api" {
  application_id = azuread_application.appreg_frontend.id
  api_client_id  = azuread_application.appreg_api.client_id
  scope_ids      = [azuread_application_permission_scope.create_person.scope_id]

}

resource "azuread_service_principal" "frontend" {
  client_id    = azuread_application.appreg_frontend.client_id
  use_existing = true
}
