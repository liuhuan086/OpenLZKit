locals {
  policy_tags = {
    for key, policy in var.policies :
    key => merge(var.common_tags, policy.tags)
  }
}

resource "alicloud_resource_manager_control_policy" "this" {
  for_each = var.policies

  control_policy_name = "${var.name_prefix}${each.value.name}"
  description         = each.value.description
  effect_scope        = each.value.effect_scope
  policy_document     = each.value.policy_document
  tags                = local.policy_tags[each.key]
}

resource "alicloud_resource_manager_control_policy_attachment" "this" {
  for_each = var.attachments

  policy_id = alicloud_resource_manager_control_policy.this[each.value.policy_key].id
  target_id = each.value.target_id

  lifecycle {
    precondition {
      condition     = contains(keys(var.policies), each.value.policy_key)
      error_message = "Each attachment policy_key must exist in var.policies."
    }
  }
}
