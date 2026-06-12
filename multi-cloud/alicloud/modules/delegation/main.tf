locals {
  share_tags = {
    for key, share in var.resource_shares :
    key => merge(var.common_tags, share.tags)
  }
}

resource "alicloud_resource_manager_delegated_administrator" "this" {
  for_each = var.delegated_administrators

  account_id        = each.value.account_id
  service_principal = each.value.service_principal
}

resource "alicloud_cloud_sso_delegate_account" "this" {
  count = var.cloud_sso_delegate_account_id == null ? 0 : 1

  account_id = var.cloud_sso_delegate_account_id
}

resource "alicloud_resource_manager_resource_share" "this" {
  for_each = var.resource_shares

  resource_share_name   = "${var.name_prefix}${each.value.name}"
  allow_external_targets = each.value.allow_external_targets
  permission_names       = each.value.permission_names
  resource_arns          = each.value.resource_arns
  targets                = each.value.targets
  resource_group_id      = each.value.resource_group_id
  tags                   = local.share_tags[each.key]

  dynamic "resources" {
    for_each = each.value.resources
    content {
      resource_id   = resources.value.resource_id
      resource_type = resources.value.resource_type
    }
  }

  dynamic "resource_properties" {
    for_each = each.value.resource_properties
    content {
      resource_arn = resource_properties.value.resource_arn
      property     = resource_properties.value.property
    }
  }
}
