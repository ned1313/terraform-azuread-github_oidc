module "development_branch" {
  source = "../.."

  identity_name   = "dev-oidc-identity"
  repository_name = "ned1313/vnet-deployment"
  entity_type     = "ref"
  ref_branch      = "development"
}

output "service_principal" {
  value = module.development_branch.service_principal
}