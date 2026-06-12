locals {
  role_system_policies = merge(concat([{}], [
    for role_key, role in var.access_roles : {
      for policy in role.system_policies :
      "${role_key}:${policy}" => {
        role   = role_key
        policy = policy
      }
    }
  ])...)

  role_tags = {
    for key, role in var.access_roles :
    key => merge(var.common_tags, role.tags)
  }

  share_tags = {
    for key, share in var.resource_shares :
    key => merge(var.common_tags, share.tags)
  }

  assume_role_policies = {
    for key, role in var.access_roles : key => jsonencode({
      Version = "1"
      Statement = [
        merge({
          Effect    = "Allow"
          Action    = "sts:AssumeRole"
          Principal = { RAM = role.trusted_principals }
        }, role.condition == null ? {} : { Condition = role.condition })
      ]
    })
  }
}

resource "alicloud_ram_role" "cross_account" {
  for_each = var.access_roles

  role_name                   = "${var.name_prefix}${each.value.role_name}"
  description                 = each.value.description
  max_session_duration        = var.max_session_duration
  assume_role_policy_document = local.assume_role_policies[each.key]
  tags                        = local.role_tags[each.key]
}

resource "alicloud_ram_role_policy_attachment" "system" {
  for_each = local.role_system_policies

  role_name   = alicloud_ram_role.cross_account[each.value.role].role_name
  policy_name = each.value.policy
  policy_type = "System"
}

resource "alicloud_resource_manager_resource_share" "this" {
  for_each = var.resource_shares

  resource_share_name   = "${var.name_prefix}${each.value.name}"
  allow_external_targets = each.value.allow_external_targets
  permission_names       = each.value.permission_names
  resource_arns          = each.value.resource_arns
  targets                = each.value.targets
  tags                   = local.share_tags[each.key]

  dynamic "resources" {
    for_each = each.value.resources
    content {
      resource_id   = resources.value.resource_id
      resource_type = resources.value.resource_type
    }
  }
}
