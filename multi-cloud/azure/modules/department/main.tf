locals {
  admin_assignments = { for k, d in var.departments : k => d if d.admin_principal_id != null }
  budgets           = { for k, d in var.departments : k => d if d.budget_amount != null }
}

resource "azurerm_management_group" "this" {
  for_each = var.departments

  name                       = "${var.name_prefix}dept-${each.key}"
  display_name               = each.value.display_name
  parent_management_group_id = var.parent_management_group_id
}

# Department admin RBAC, scoped to the department's management group only.
resource "azurerm_role_assignment" "admin" {
  for_each = local.admin_assignments

  scope                = azurerm_management_group.this[each.key].id
  principal_id         = each.value.admin_principal_id
  principal_type       = each.value.admin_principal_type
  role_definition_name = each.value.admin_role
}

# Department budget for cost attribution.
resource "azurerm_consumption_budget_management_group" "this" {
  for_each = local.budgets

  name                = "${var.name_prefix}dept-${each.key}-budget"
  management_group_id = azurerm_management_group.this[each.key].id
  amount              = each.value.budget_amount

  time_period {
    start_date = each.value.budget_start_date
  }

  notification {
    threshold      = 90
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = each.value.budget_contact_emails
  }
}
