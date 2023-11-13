# The SP is going to need access to the Application.ReadWrite.OwnedBy role of the 
# MicrosoftGraph API in order to create/manage applications provisioned by it
# so lookup the necessary application and role id
data "azuread_application_published_app_ids" "well_known" {}

resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
  use_existing = true
}

# Create an application
resource "azuread_application" "oidc" {
  display_name = var.identity_name
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.OwnedBy"]
      type = "Role"
    }
  }
}

# Create a federated identity
locals {
  ref_string     = var.entity_type == "ref" && var.ref_branch != null ? "refs/heads/${var.ref_branch}" : var.entity_type == "ref" && var.ref_tag != null ? "refs/tags/${var.ref_tag}" : null
  subject_string = var.entity_type == "environment" ? "environment:${var.environment_name}" : var.entity_type == "ref" ? "ref:${local.ref_string}" : "pull_request"
}

resource "azuread_application_federated_identity_credential" "oidc" {
  application_id = azuread_application.oidc.id
  display_name   = azuread_application.oidc.display_name
  description    = "GitHub OIDC for ${var.repository_name}."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repository_name}:${local.subject_string}"
}

# Create a service principal
data "azuread_client_config" "current" {}

locals {
  owner_id = var.owner_id != null ? var.owner_id : data.azuread_client_config.current.object_id
}

resource "azuread_service_principal" "oidc" {
  client_id = azuread_application.oidc.client_id
  owners    = [local.owner_id]
}

#  Grant admin consent for permissions requested by the SP in the required_resource_access block
resource "azuread_app_role_assignment" "oidc" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.OwnedBy"]
  principal_object_id = azuread_service_principal.oidc.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}