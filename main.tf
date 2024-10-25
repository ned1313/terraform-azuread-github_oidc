# Create an application
resource "azuread_application_registration" "oidc" {
  display_name = var.identity_name
}

# Create federated identities
resource "azuread_application_federated_identity_credential" "branches" {
  for_each       = toset(var.ref_branches)
  application_id = azuread_application_registration.oidc.id
  display_name   = "${azuread_application_registration.oidc.display_name}-branch-${each.value}"
  description    = "GitHub OIDC for ${var.repository_name} and branch ${each.value}."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repository_name}:ref:refs/heads/${each.value}"
}

resource "azuread_application_federated_identity_credential" "tags" {
  for_each       = toset(var.ref_tags)
  application_id = azuread_application_registration.oidc.id
  display_name   = "${azuread_application_registration.oidc.display_name}-tag-${each.value}"
  description    = "GitHub OIDC for ${var.repository_name} and tag ${each.value}."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repository_name}:ref:refs/tags/${each.value}"
}

resource "azuread_application_federated_identity_credential" "environments" {
  for_each       = toset(var.environment_names)
  application_id = azuread_application_registration.oidc.id
  display_name   = "${azuread_application_registration.oidc.display_name}-environment-${each.value}"
  description    = "GitHub OIDC for ${var.repository_name} and environment ${each.value}."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repository_name}:environment:${each.value}"
}

resource "azuread_application_federated_identity_credential" "pr" {
  # Create a pull request federated identity if create_pr_identity is true or entity_type is pull_request
  count          = var.create_pr_identity || var.entity_type == "pull_request" ? 1 : 0
  application_id = azuread_application_registration.oidc.id
  display_name   = "${azuread_application_registration.oidc.display_name}-pr"
  description    = "GitHub OIDC for ${var.repository_name} Pull Requests"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.repository_name}:pull_request"
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
