# Return the full service principal object
output "service_principal" {
  value       = azuread_service_principal.oidc
  description = "The full service principal object associated with the application."
}

output "azuread_application" {
  value       = azuread_application_registration.oidc
  description = "The full application object associated with the service principal."
}