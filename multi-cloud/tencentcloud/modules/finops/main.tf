# Enable tag keys for cost allocation (FinOps attribution).
resource "tencentcloud_billing_allocation_tag" "this" {
  for_each = toset(var.allocation_tag_keys)

  tag_key = each.value
}

resource "tencentcloud_billing_budget" "this" {
  for_each = var.budgets

  budget_name  = each.value.budget_name
  budget_quota = each.value.budget_quota
  bill_type    = each.value.bill_type
  cycle_type   = each.value.cycle_type
  fee_type     = each.value.fee_type
  plan_type    = each.value.plan_type
  period_begin = each.value.period_begin
  period_end   = each.value.period_end
  budget_note  = each.value.budget_note

  dynamic "warn_json" {
    for_each = each.value.warn_thresholds
    content {
      warn_type       = warn_json.value.warn_type
      cal_type        = warn_json.value.cal_type
      threshold_value = warn_json.value.threshold_value
    }
  }
}
