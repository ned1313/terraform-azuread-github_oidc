# Create an application
resource "azuread_application_registration" "oidc" {
  display_name = var.identity_name
}

# Create a federated identity
locals {
  ref_string     = var.entity_type == "ref" && var.ref_branch != null ? "refs/heads/${var.ref_branch}" : var.entity_type == "ref" && var.ref_tag != null ? "refs/tags/${var.ref_tag}" : null
  subject_string = var.entity_type == "environment" ? "environment:${var.environment_name}" : var.entity_type == "ref" ? "ref:${local.ref_string}" : "pull_request"
}

resource "azuread_application_federated_identity_credential" "oidc" {
  application_id = azuread_application_registration.oidc.id
  display_name   = azuread_application_registration.oidc.display_name
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
  client_id = azuread_application_registration.oidc.client_id
  owners    = [local.owner_id]
}
