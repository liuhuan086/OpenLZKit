resource "azurerm_consumption_budget_management_group" "this" {
  for_each = var.budgets

  name                = "${var.name_prefix}${each.key}"
  management_group_id = each.value.management_group_id
  amount              = each.value.amount
  time_grain          = each.value.time_grain

  time_period {
    start_date = each.value.start_date
  }

  dynamic "notification" {
    for_each = { for i, n in each.value.notifications : tostring(i) => n }
    content {
      threshold      = notification.value.threshold
      operator       = notification.value.operator
      threshold_type = notification.value.threshold_type
      contact_emails = notification.value.contact_emails
    }
  }
}
