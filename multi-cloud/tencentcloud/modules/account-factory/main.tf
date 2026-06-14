resource "tencentcloud_organization_org_member" "this" {
  for_each = var.members

  name           = each.value.name
  node_id        = each.value.node_id
  policy_type    = each.value.policy_type
  permission_ids = each.value.permission_ids
  tags           = merge(var.common_tags, each.value.tags)
}
