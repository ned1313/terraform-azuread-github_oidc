module "pull_request" {
  source = "../.."

  identity_name   = "dev-oidc-identity"
  repository_name = "ned1313/vnet-deployment"
  entity_type     = "pull-request"
}

output "service_principal" {
  value = module.pull_request.service_principal
}