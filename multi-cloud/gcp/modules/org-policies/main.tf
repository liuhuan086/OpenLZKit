resource "google_org_policy_policy" "boolean" {
  for_each = var.boolean_policies

  name   = "${var.parent}/policies/${each.value.constraint}"
  parent = var.parent

  spec {
    rules {
      enforce = each.value.enforce ? "TRUE" : "FALSE"
    }
  }
}

resource "google_org_policy_policy" "list" {
  for_each = var.list_policies

  name   = "${var.parent}/policies/${each.value.constraint}"
  parent = var.parent

  spec {
    rules {
      allow_all = each.value.allow_all == null ? null : (each.value.allow_all ? "TRUE" : "FALSE")
      deny_all  = each.value.deny_all == null ? null : (each.value.deny_all ? "TRUE" : "FALSE")

      dynamic "values" {
        for_each = (each.value.allowed_values != null || each.value.denied_values != null) ? [1] : []
        content {
          allowed_values = each.value.allowed_values
          denied_values  = each.value.denied_values
        }
      }
    }
  }
}
