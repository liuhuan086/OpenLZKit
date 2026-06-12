locals {
  permission_boundary_tags = {
    for key, boundary in var.permission_boundaries :
    key => merge(var.common_tags, boundary.tags)
  }

  managed_policy_tags = {
    for key, policy in var.managed_policies :
    key => merge(var.common_tags, policy.tags)
  }
}

resource "aws_iam_account_alias" "this" {
  count = var.account_alias == null ? 0 : 1

  account_alias = var.account_alias
}

resource "aws_iam_account_password_policy" "this" {
  count = var.create_account_password_policy ? 1 : 0

  minimum_password_length        = var.password_policy.minimum_password_length
  require_lowercase_characters   = var.password_policy.require_lowercase_characters
  require_uppercase_characters   = var.password_policy.require_uppercase_characters
  require_numbers                = var.password_policy.require_numbers
  require_symbols                = var.password_policy.require_symbols
  allow_users_to_change_password = var.password_policy.allow_users_to_change_password
  hard_expiry                    = var.password_policy.hard_expiry
  max_password_age               = var.password_policy.max_password_age
  password_reuse_prevention      = var.password_policy.password_reuse_prevention
}

resource "aws_iam_policy" "permission_boundary" {
  for_each = var.permission_boundaries

  name        = "${var.name_prefix}${each.value.name}"
  description = each.value.description
  path        = each.value.path
  policy      = each.value.policy
  tags        = local.permission_boundary_tags[each.key]
}

resource "aws_iam_policy" "managed" {
  for_each = var.managed_policies

  name        = "${var.name_prefix}${each.value.name}"
  description = each.value.description
  path        = each.value.path
  policy      = each.value.policy
  tags        = local.managed_policy_tags[each.key]
}
