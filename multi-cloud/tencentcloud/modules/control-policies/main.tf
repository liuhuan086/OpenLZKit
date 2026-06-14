resource "tencentcloud_organization_org_manage_policy" "this" {
  for_each = var.policies

  name        = "${var.name_prefix}${each.key}"
  content     = each.value.content
  description = each.value.description
  type        = each.value.type
}

resource "tencentcloud_organization_org_manage_policy_target" "this" {
  for_each = var.attachments

  policy_id   = tonumber(tencentcloud_organization_org_manage_policy.this[each.value.policy_key].id)
  target_id   = each.value.target_id
  target_type = each.value.target_type
}
