resource "tencentcloud_organization_org_share_unit" "this" {
  for_each = var.share_units

  name        = "${var.name_prefix}${each.value.name}"
  area        = each.value.area
  description = each.value.description
}

resource "tencentcloud_organization_org_share_unit_resource" "this" {
  for_each = var.shared_resources

  unit_id             = tencentcloud_organization_org_share_unit.this[each.value.unit_key].id
  area                = each.value.area
  product_resource_id = each.value.product_resource_id
  type                = each.value.type
}

# Delegate management to a member sub-account via an auth policy (least-privilege).
resource "tencentcloud_organization_member_auth_policy_attachment" "this" {
  for_each = var.member_delegations

  org_sub_account_uin = each.value.org_sub_account_uin
  policy_id           = each.value.policy_id
}
