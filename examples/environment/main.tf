module "development_env" {
  source = "../.."

  identity_name     = "dev-oidc-identity"
  repository_name   = "ned1313/vnet-deployment"
  entity_type       = "environment"
  environment_names = ["development"]
}

output "service_principal" {
  description = "Azure Service Principal"
  value       = module.development_env.service_principal
}
