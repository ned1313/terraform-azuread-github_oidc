module "release_tag" {
  source = "../.."

  identity_name   = "dev-oidc-identity"
  repository_name = "ned1313/vnet-deployment"
  entity_type     = "ref"
  ref_tags        = ["v1.0"]
}

output "service_principal" {
  description = "Azure Service Principal"
  value       = module.release_tag.service_principal
}
