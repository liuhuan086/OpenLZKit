locals {
  child_nodes = merge(concat([{}], [
    for parent_key, parent in var.nodes : {
      for child_key, child in parent.children :
      "${parent_key}/${child_key}" => {
        parent_key = parent_key
        name       = child.name
      }
    }
  ])...)

  node_ids = merge(
    { for k, n in tencentcloud_organization_org_node.top : k => n.id },
    { for k, n in tencentcloud_organization_org_node.child : k => n.id },
  )
}

resource "tencentcloud_organization_org_node" "top" {
  for_each = var.nodes

  name           = "${var.name_prefix}${each.value.name}"
  parent_node_id = var.root_node_id
  tags           = var.tags
}

resource "tencentcloud_organization_org_node" "child" {
  for_each = local.child_nodes

  name           = "${var.name_prefix}${each.value.name}"
  parent_node_id = tonumber(tencentcloud_organization_org_node.top[each.value.parent_key].id)
  tags           = var.tags
}
