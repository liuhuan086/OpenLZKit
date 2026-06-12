resource "azurerm_role_definition" "this" {
  for_each = var.custom_roles

  name              = "${var.name_prefix}${each.key}"
  scope             = each.value.scope
  description       = each.value.description
  assignable_scopes = each.value.assignable_scopes

  permissions {
    actions          = each.value.actions
    not_actions      = each.value.not_actions
    data_actions     = each.value.data_actions
    not_data_actions = each.value.not_data_actions
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope          = each.value.scope
  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type
  description    = each.value.description

  role_definition_name = each.value.custom_role_key == null ? each.value.role_definition_name : null
  role_definition_id   = each.value.custom_role_key == null ? null : azurerm_role_definition.this[each.value.custom_role_key].role_definition_resource_id
}
