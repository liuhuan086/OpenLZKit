locals {
  admin_roles     = { for k, d in var.departments : k => d if d.create_admin_role }
  policy_attaches = { for k, d in var.departments : k => d if d.manage_policy_id != null }
}

resource "tencentcloud_organization_org_node" "this" {
  for_each = var.departments

  name           = "${var.name_prefix}dept-${each.value.name}"
  parent_node_id = var.parent_node_id
}

# Department admin role, assumed from the management account.
resource "tencentcloud_cam_role" "admin" {
  for_each = local.admin_roles

  name        = "${var.name_prefix}dept-${each.key}-admin"
  description = "Department admin role for ${each.value.name}."

  document = jsonencode({
    version = "2.0"
    statement = [{
      effect    = "allow"
      action    = ["name/sts:AssumeRole"]
      principal = { qcs = ["qcs::cam::uin/${var.management_uin}:root"] }
    }]
  })
}

# Attach a manage policy to the department node (inherited by its members).
resource "tencentcloud_organization_org_manage_policy_target" "this" {
  for_each = local.policy_attaches

  policy_id   = each.value.manage_policy_id
  target_id   = tonumber(tencentcloud_organization_org_node.this[each.key].id)
  target_type = "NODE"
}
