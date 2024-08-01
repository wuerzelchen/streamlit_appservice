resource "azuread_application" "appreg_frontend" {
  # The display name of the application with locals joined
  display_name                   = "appreg-frontend-${local.projectname}-${random_id.suffix.hex}"
  identifier_uris                = ["api://frontend-${local.projectname}-${random_id.suffix.hex}"]
  owners                         = [data.azurerm_client_config.current.object_id]
  sign_in_audience               = "AzureADMyOrg"
  fallback_public_client_enabled = true
  required_resource_access {
    resource_app_id = "f1332c40-18da-48cd-8abe-e2c492513916"

    resource_access {
      id   = "c7f8fc4f-802f-4f60-90b2-bb199a031287"
      type = "Scope"
    }
  }

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access example on behalf of the signed-in user."
      admin_consent_display_name = "Access example"
      enabled                    = true
      id                         = "96183846-204b-4b43-82e1-5d2222eb4b9b"
      type                       = "User"
      user_consent_description   = "Allow the application to access example on your behalf."
      user_consent_display_name  = "Access example"
      value                      = "user_impersonation"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Administer the example application"
      admin_consent_display_name = "Administer"
      enabled                    = true
      id                         = "be98fa3e-ab5b-4b11-83d9-04ba2b7946bc"
      type                       = "Admin"
      value                      = "administer"
    }
  }

  feature_tags {
    enterprise = true
    gallery    = true
  }

  single_page_application {
    redirect_uris = ["http://localhost:5005/", "https://slentra.livelyhill-6cbc2781.francecentral.azurecontainerapps.io/"]
  }
}
