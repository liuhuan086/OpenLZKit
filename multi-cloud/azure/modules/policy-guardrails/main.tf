resource "azurerm_policy_definition" "this" {
  for_each = var.policy_definitions

  name                = "${var.name_prefix}${each.key}"
  display_name        = each.value.display_name
  description         = each.value.description
  policy_type         = "Custom"
  mode                = each.value.mode
  management_group_id = each.value.management_group_id
  policy_rule         = each.value.policy_rule
  parameters          = each.value.parameters
}

resource "azurerm_management_group_policy_assignment" "this" {
  for_each = var.policy_assignments

  name                = each.value.name
  display_name        = each.value.display_name
  management_group_id = each.value.management_group_id
  enforce             = each.value.enforce
  location            = each.value.location
  parameters          = each.value.parameters

  policy_definition_id = each.value.policy_definition_key == null ? each.value.policy_definition_id : azurerm_policy_definition.this[each.value.policy_definition_key].id
}
