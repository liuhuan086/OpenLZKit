module "cross_account_access" {
  source = "../../modules/cross-account-access"

  name_prefix     = "lz-"
  oidc_providers  = var.oidc_providers
  access_roles    = var.access_roles
  resource_shares = var.resource_shares
}
