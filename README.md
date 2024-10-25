# terraform-azuread-github_oidc

Terraform module to create an Azure AD application, service principal, and federated identity for GitHub-based OIDC authentication.

Creates the following resources:

* Azure AD application (azuread_application)
* Federated Identity Credential (azuread_application_federated_identity_credential)
* Azure AD Service Principal (azuread_service_principal)

The output from the module is the full `azuread_service_principal` object, since you may need access to all or some of the attributes like `object_id`, `application_id`, or `application_tenant_id`.

The module is intended to support the use of GitHub Actions OIDC authentication for Azure AD.

## Usage

```hcl
# Use the module with a GitHub environment named development
module "development_env" {
    source           = "ned1313/github_oidc/azuread"
    version          = "2.0"

    identity_name    = "dev-oidc-identity"
    repository_name  = "ned1313/vnet-deployment"
    entity_type      = "environment"
    environment_names = ["development"]
}
```

## Notes

Refer to the following documentation on GitHub and Azure AD for using the federated identity with GitHub Actions:

* [Authenticate from Azure to GitHub](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows)
* [Configuring Open ID Connect in Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
