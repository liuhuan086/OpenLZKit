locals {
  # Flatten one level of children into "<parent_key>/<child_key>".
  child_groups = merge([
    for parent_key, parent in var.management_groups : {
      for child_key, child in parent.children :
      "${parent_key}/${child_key}" => {
        parent_key   = parent_key
        child_key    = child_key
        display_name = child.display_name
      }
    }
  ]...)

  management_group_ids = merge(
    { for k, mg in azurerm_management_group.top : k => mg.id },
    { for k, mg in azurerm_management_group.child : k => mg.id },
  )
}

resource "azurerm_management_group" "top" {
  for_each = var.management_groups

  name                       = "${var.name_prefix}${each.key}"
  display_name               = each.value.display_name
  parent_management_group_id = var.parent_management_group_id
}

resource "azurerm_management_group" "child" {
  for_each = local.child_groups

  name                       = "${var.name_prefix}${each.value.parent_key}-${each.value.child_key}"
  display_name               = each.value.display_name
  parent_management_group_id = azurerm_management_group.top[each.value.parent_key].id
}
