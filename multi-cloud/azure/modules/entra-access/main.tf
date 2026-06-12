resource "azuread_group" "this" {
  for_each = var.groups

  display_name     = "${var.name_prefix}${each.value.display_name}"
  description      = each.value.description
  security_enabled = true
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azuread_group.this[each.value.group_key].object_id
  principal_type       = "Group"
  description          = each.value.description
}
