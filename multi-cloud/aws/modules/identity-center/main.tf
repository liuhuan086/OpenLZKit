locals {
  permission_set_tags = {
    for key, permission_set in var.permission_sets :
    key => merge(var.common_tags, permission_set.tags)
  }

  managed_policy_attachments = merge(concat([{}], [
    for permission_set_key, permission_set in var.permission_sets : {
      for policy_arn in permission_set.managed_policy_arns :
      "${permission_set_key}:${policy_arn}" => {
        permission_set = permission_set_key
        policy_arn     = policy_arn
      }
    }
  ])...)

  inline_policies = {
    for key, permission_set in var.permission_sets :
    key => permission_set.inline_policy
    if permission_set.inline_policy != null
  }
}

resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = var.identity_store_id
  display_name      = each.value.display_name
  description       = each.value.description
}

resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = var.identity_store_id
  user_name         = each.value.user_name
  display_name      = each.value.display_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.email
    primary = true
    type    = "work"
  }
}

resource "aws_identitystore_group_membership" "this" {
  for_each = var.group_memberships

  identity_store_id = var.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group_key].group_id
  member_id         = aws_identitystore_user.this[each.value.user_key].user_id

  lifecycle {
    precondition {
      condition     = contains(keys(var.groups), each.value.group_key)
      error_message = "Each group_membership group_key must exist in var.groups."
    }

    precondition {
      condition     = contains(keys(var.users), each.value.user_key)
      error_message = "Each group_membership user_key must exist in var.users."
    }
  }
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.value.name
  description      = each.value.description
  instance_arn     = var.instance_arn
  relay_state      = each.value.relay_state
  session_duration = each.value.session_duration
  tags             = local.permission_set_tags[each.key]
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.managed_policy_attachments

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  managed_policy_arn = each.value.policy_arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = local.inline_policies

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.assignments

  instance_arn       = var.instance_arn
  permission_set_arn = try(aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn, null)
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.target_id
  target_type        = each.value.target_type

  lifecycle {
    precondition {
      condition     = contains(keys(var.permission_sets), each.value.permission_set_key)
      error_message = "Each assignment permission_set_key must exist in var.permission_sets."
    }
  }
}
