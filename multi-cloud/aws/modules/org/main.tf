data "aws_organizations_organization" "this" {}

locals {
  root_id = data.aws_organizations_organization.this.roots[0].id

  child_ous = merge(concat([{}], [
    for parent_key, parent in var.organizational_units : {
      for child_key, child in parent.children :
      "${parent_key}/${child_key}" => {
        parent_key = parent_key
        name       = child.name
        tags       = child.tags
      }
    }
  ])...)

  ou_ids = merge(
    { for k, ou in aws_organizations_organizational_unit.top : k => ou.id },
    { for k, ou in aws_organizations_organizational_unit.child : k => ou.id },
  )
}

resource "aws_organizations_organizational_unit" "top" {
  for_each = var.organizational_units

  name      = "${var.name_prefix}${each.value.name}"
  parent_id = local.root_id
  tags      = merge(var.tags, each.value.tags)
}

resource "aws_organizations_organizational_unit" "child" {
  for_each = local.child_ous

  name      = "${var.name_prefix}${each.value.name}"
  parent_id = aws_organizations_organizational_unit.top[each.value.parent_key].id
  tags      = merge(var.tags, each.value.tags)
}
