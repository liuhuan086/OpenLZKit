locals {
  directory_id = var.create_directory ? alicloud_cloud_sso_directory.this[0].id : var.directory_id

  user_tags = {
    for key, user in var.users :
    key => merge(var.common_tags, user.tags)
  }

  assignment_principal_ids = {
    for key, assignment in var.assignments :
    key => (
      assignment.group_key != null ? alicloud_cloud_sso_group.this[assignment.group_key].group_id :
      assignment.user_key != null ? alicloud_cloud_sso_user.this[assignment.user_key].user_id :
      assignment.principal_id
    )
  }
}

resource "alicloud_cloud_sso_directory" "this" {
  count = var.create_directory ? 1 : 0

  directory_name                 = var.directory_name
  directory_global_access_status = var.directory_global_access_status
  mfa_authentication_status      = var.mfa_authentication_status
  scim_synchronization_status    = var.scim_synchronization_status

  login_preference {
    allow_user_to_get_credentials = var.allow_user_to_get_credentials
    login_network_masks           = var.login_network_masks
  }
}

resource "alicloud_cloud_sso_group" "this" {
  for_each = var.groups

  directory_id = local.directory_id
  group_name   = each.value.name
  description  = each.value.description
}

resource "alicloud_cloud_sso_user" "this" {
  for_each = var.users

  directory_id = local.directory_id
  user_name    = each.value.user_name
  display_name = each.value.display_name
  email        = each.value.email
  first_name   = each.value.first_name
  last_name    = each.value.last_name
  description  = each.value.description
  status       = each.value.status
  tags         = local.user_tags[each.key]
}

resource "alicloud_cloud_sso_user_attachment" "this" {
  for_each = var.group_memberships

  directory_id = local.directory_id
  group_id     = alicloud_cloud_sso_group.this[each.value.group_key].group_id
  user_id      = alicloud_cloud_sso_user.this[each.value.user_key].user_id

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

resource "alicloud_cloud_sso_access_configuration" "this" {
  for_each = var.access_configurations

  directory_id                     = local.directory_id
  access_configuration_name        = each.value.name
  description                      = each.value.description
  session_duration                 = each.value.session_duration
  relay_state                      = each.value.relay_state
  force_remove_permission_policies = each.value.force_remove_permission_policies

  dynamic "permission_policies" {
    for_each = each.value.permission_policies
    content {
      permission_policy_name     = permission_policies.value.name
      permission_policy_type     = permission_policies.value.type
      permission_policy_document = permission_policies.value.document
    }
  }
}

resource "alicloud_cloud_sso_access_assignment" "this" {
  for_each = var.assignments

  directory_id            = local.directory_id
  access_configuration_id = alicloud_cloud_sso_access_configuration.this[each.value.access_configuration_key].access_configuration_id
  principal_id            = local.assignment_principal_ids[each.key]
  principal_type          = each.value.principal_type
  target_id               = each.value.target_id
  target_type             = each.value.target_type
  deprovision_strategy    = each.value.deprovision_strategy

  lifecycle {
    precondition {
      condition     = contains(keys(var.access_configurations), each.value.access_configuration_key)
      error_message = "Each assignment access_configuration_key must exist in var.access_configurations."
    }

    precondition {
      condition     = local.assignment_principal_ids[each.key] != null
      error_message = "Each assignment must set principal_id or reference a group_key/user_key."
    }
  }
}

resource "alicloud_cloud_sso_access_configuration_provisioning" "this" {
  for_each = var.provisionings

  directory_id            = local.directory_id
  access_configuration_id = alicloud_cloud_sso_access_configuration.this[each.value.access_configuration_key].access_configuration_id
  target_id               = each.value.target_id
  target_type             = each.value.target_type

  lifecycle {
    precondition {
      condition     = contains(keys(var.access_configurations), each.value.access_configuration_key)
      error_message = "Each provisioning access_configuration_key must exist in var.access_configurations."
    }
  }
}
