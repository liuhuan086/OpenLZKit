# Module: azure/finops

Creates **management-group budgets** with threshold alerts (the Azure FinOps
cost-control primitive). Tag enforcement is handled by `policy-guardrails` (a
built-in "Require a tag" assignment), so this module stays focused on budgets.

## Responsibilities

- Create `azurerm_consumption_budget_management_group` budgets with notifications.

It does **not**: enforce tags (use `policy-guardrails`), create cost exports, or
manage subscription-level budgets.

## Usage

```hcl
module "finops" {
  source = "../../modules/finops"

  budgets = {
    platform-monthly = {
      management_group_id = var.root_management_group_id
      amount              = 1000
      start_date          = "2026-01-01T00:00:00Z"
      notifications = [
        { threshold = 80, contact_emails = ["finops@example.com"] },
      ]
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on budget names. |
| `budgets` | `map(object)` | `{}` | Budgets: amount, time_grain, start_date, notifications. |

## Outputs

| Name | Description |
|---|---|
| `budget_ids` | Map of budget key to id. |

## Notes

- Use `Actual` and `Forecasted` notifications for early warning.
- Pair with the FinOps tag policy so cost can be attributed (owner/cost_center/env).

Validated via [live/60-finops](../../live/60-finops); see [../../tests](../../tests).
