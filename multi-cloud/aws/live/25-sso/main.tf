module "identity_center" {
  source = "../../modules/identity-center"

  instance_arn      = var.instance_arn
  identity_store_id = var.identity_store_id
  permission_sets   = var.permission_sets
  assignments       = var.assignments
  groups            = var.groups
  users             = var.users
  group_memberships = var.group_memberships
}
