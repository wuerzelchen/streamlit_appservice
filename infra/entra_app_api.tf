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
    oauth2_permission_scope {
      admin_consent_description  = "Allows the app to create a Person on your behalf."
      admin_consent_display_name = "Create Person"
      id                         = "c7f8fc4f-802f-4f60-90b2-bb199a031287"
      enabled                    = true
      type                       = "User"
      user_consent_description   = "Allows the app to create a Person on your behalf."
      user_consent_display_name  = "Create Person"
      value                      = "Person.Create"
    }
  }
  required_resource_access {
    resource_app_id = "f1332c40-18da-48cd-8abe-e2c492513916"
    resource_access {
      id   = "c7f8fc4f-802f-4f60-90b2-bb199a031287"
      type = "Scope"
    }
  }
  required_resource_access {
    resource_app_id = "123cd850-d9df-40bd-94d5-c9f07b7fa203" # Azure OSSRDBMS Database Permission
    resource_access {
      id   = "cef99a3a-4cd3-4408-8143-4375d1e38a17"
      type = "Scope"

    }
  }
  feature_tags {
    enterprise = true
    gallery    = true
  }

  web {
    redirect_uris = ["http://localhost:5005/"]
  }
}

# client credentials
resource "azuread_application_password" "appreg_api_password" {
  display_name   = "appreg-api-password-${local.projectname}-${random_id.suffix.hex}"
  application_id = azuread_application.appreg_api.id
}
