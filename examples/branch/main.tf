module "development_branch" {
  source = "../.."

  identity_name   = "dev-oidc-identity"
  repository_name = "ned1313/vnet-deployment"
  entity_type     = "ref"
  ref_branches    = ["development"]
}

output "service_principal" {
  description = "Azure Service Principal"
  value       = module.development_branch.service_principal
}
