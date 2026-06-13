locals {
  admin_bindings = { for k, d in var.departments : k => d if d.admin_member != null }
  budgets        = { for k, d in var.departments : k => d if d.budget_units != null }
}

resource "google_folder" "this" {
  for_each = var.departments

  display_name = "${var.name_prefix}dept-${each.value.display_name}"
  parent       = var.parent
}

# Department admin IAM, scoped to the department folder only.
resource "google_folder_iam_member" "admin" {
  for_each = local.admin_bindings

  folder = google_folder.this[each.key].name
  role   = each.value.admin_role
  member = each.value.admin_member
}

# Department budget scoped to the department folder via resource ancestors.
resource "google_billing_budget" "this" {
  for_each = local.budgets

  billing_account = var.billing_account
  display_name    = "${var.name_prefix}dept-${each.key}-budget"

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(each.value.budget_units)
    }
  }

  budget_filter {
    resource_ancestors = [google_folder.this[each.key].name]
  }

  dynamic "threshold_rules" {
    for_each = each.value.threshold_percents
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }
}
