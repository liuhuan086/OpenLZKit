locals {
  role_policy_pairs = merge(concat([{}], [
    for role_key, role in var.roles : {
      for policy_key in role.custom_policy_keys :
      "${role_key}:${policy_key}" => {
        role_key   = role_key
        policy_key = policy_key
      }
    }
  ])...)
}

resource "tencentcloud_cam_policy" "this" {
  for_each = var.custom_policies

  name        = "${var.name_prefix}${each.key}"
  document    = each.value.document
  description = each.value.description
}

resource "tencentcloud_cam_role" "this" {
  for_each = var.roles

  name             = "${var.name_prefix}${each.key}"
  document         = each.value.document
  description      = each.value.description
  session_duration = each.value.session_duration
}

resource "tencentcloud_cam_role_policy_attachment" "this" {
  for_each = local.role_policy_pairs

  role_id   = tencentcloud_cam_role.this[each.value.role_key].id
  policy_id = tonumber(tencentcloud_cam_policy.this[each.value.policy_key].id)
}
