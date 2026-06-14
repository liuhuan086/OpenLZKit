locals {
  group_policy_pairs = merge(concat([{}], [
    for group_key, group in var.groups : {
      for policy_id in group.policy_ids :
      "${group_key}:${policy_id}" => {
        group_key = group_key
        policy_id = policy_id
      }
    }
  ])...)
}

resource "tencentcloud_cam_group" "this" {
  for_each = var.groups

  name   = "${var.name_prefix}${each.value.name}"
  remark = each.value.remark
}

resource "tencentcloud_cam_group_policy_attachment" "this" {
  for_each = local.group_policy_pairs

  group_id  = tonumber(tencentcloud_cam_group.this[each.value.group_key].id)
  policy_id = each.value.policy_id
}
