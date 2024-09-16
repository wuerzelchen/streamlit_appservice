resource "azuread_application" "appreg_api" {
  # The display name of the application with locals joined
  display_name                   = "appreg-api-${local.projectname}-${random_id.suffix.hex}"
  identifier_uris                = ["api://api-${local.projectname}-${random_id.suffix.hex}"]
  owners                         = [data.azurerm_client_config.current.object_id]
  sign_in_audience               = "AzureADMyOrg"
  fallback_public_client_enabled = false

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
  }

  feature_tags {
    enterprise = true
    gallery    = true
  }

  web {
    redirect_uris = ["http://localhost:5005/"]
  }

  # this is needed, else the permissions will be toggle on every apply
  lifecycle {
    ignore_changes = [
      api[0].oauth2_permission_scope,
      required_resource_access
    ]
  }
}

# create an azuread application api access for the permission scope create_person
resource "azuread_application_api_access" "create_person_access" {
  application_id = azuread_application.appreg_api.id
  api_client_id  = azuread_application.appreg_api.client_id
  scope_ids      = [azuread_application_permission_scope.create_person.scope_id]
}


resource "azuread_application_api_access" "postgres_access" {
  application_id = azuread_application.appreg_api.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["OssRdbms"]
  scope_ids      = [data.azuread_service_principal.ossrdbms.oauth2_permission_scope_ids["user_impersonation"]]
}

resource "azuread_application_permission_scope" "create_person" {
  application_id             = azuread_application.appreg_api.id
  scope_id                   = local.random_uuid
  type                       = "User"
  admin_consent_description  = "Allows the app to create a Person on your behalf."
  admin_consent_display_name = "Create Person"
  user_consent_description   = "Allows the app to create a Person on your behalf."
  user_consent_display_name  = "Create Person"
  value                      = "Person.Create"
}

# client credentials
resource "azuread_application_password" "appreg_api_password" {
  display_name   = "appreg-api-password-${local.projectname}-${random_id.suffix.hex}"
  application_id = azuread_application.appreg_api.id
}

resource "azuread_service_principal" "api" {
  client_id    = azuread_application.appreg_api.client_id
  use_existing = true
}
