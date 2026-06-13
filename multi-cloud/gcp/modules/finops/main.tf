resource "google_billing_budget" "this" {
  for_each = var.budgets

  billing_account = var.billing_account
  display_name    = each.value.display_name

  amount {
    specified_amount {
      currency_code = each.value.currency_code
      units         = tostring(each.value.amount_units)
    }
  }

  dynamic "budget_filter" {
    for_each = length(each.value.projects) > 0 ? [1] : []
    content {
      projects = each.value.projects
    }
  }

  dynamic "threshold_rules" {
    for_each = each.value.threshold_percents
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }
}
