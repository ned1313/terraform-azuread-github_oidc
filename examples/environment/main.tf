module "development_env" {
    source           = "../.."

    identity_name    = "dev-oidc-identity"
    repository_name  = "ned1313/vnet-deployment"
    entity_type      = "environment"
    environment_name = "development"
}

output "service_principal" {
  value = module.development_env.service_principal
}