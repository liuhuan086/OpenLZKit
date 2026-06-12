module "identity" {
  source = "../../modules/identity"

  name_prefix                    = var.name_prefix
  account_alias                  = var.account_alias
  create_account_password_policy = var.create_account_password_policy
  password_policy                = var.password_policy
  permission_boundaries          = var.permission_boundaries
  managed_policies               = var.managed_policies
  common_tags                    = var.common_tags
}
