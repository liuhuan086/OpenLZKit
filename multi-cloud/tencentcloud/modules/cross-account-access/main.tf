locals {
  role_policy_pairs = merge(concat([{}], [
    for role_key, role in var.access_roles : {
      for policy_id in role.policy_ids :
      "${role_key}:${policy_id}" => {
        role_key  = role_key
        policy_id = policy_id
      }
    }
  ])...)
}

resource "tencentcloud_cam_role" "this" {
  for_each = var.access_roles

  name             = "${var.name_prefix}${each.value.name}"
  description      = each.value.description
  session_duration = each.value.session_duration

  document = jsonencode({
    version = "2.0"
    statement = [{
      effect    = "allow"
      action    = ["name/sts:AssumeRole"]
      principal = { qcs = [for uin in each.value.trusted_uins : "qcs::cam::uin/${uin}:root"] }
    }]
  })
}

resource "tencentcloud_cam_role_policy_attachment" "this" {
  for_each = local.role_policy_pairs

  role_id   = tencentcloud_cam_role.this[each.value.role_key].id
  policy_id = each.value.policy_id
}
