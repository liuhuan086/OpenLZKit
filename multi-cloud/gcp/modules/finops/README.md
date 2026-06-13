# Module: gcp/finops

Creates **Cloud Billing budgets** with threshold alerts (the GCP FinOps
cost-control primitive). Label/tag governance is handled via `org-policies` and
`project-factory` common labels, so this module stays focused on budgets.

## Responsibilities

- Create `google_billing_budget` budgets, optionally scoped to projects, with threshold rules.

It does **not**: configure notification channels/Pub-Sub, billing export to
BigQuery, or label enforcement.

## Usage

```hcl
module "finops" {
  source          = "../../modules/finops"
  billing_account = "0X0X0X-0X0X0X-0X0X0X"

  budgets = {
    platform-monthly = { display_name = "lz-platform-monthly", amount_units = 1000 }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `billing_account` | `string` | — | Billing account id. |
| `budgets` | `map(object)` | `{}` | Budgets: amount, currency, optional projects, threshold percents. |

## Outputs

| Name | Description |
|---|---|
| `budget_ids` | Map of budget key to id. |

## Notes

- Scope budgets to projects or the whole billing account; thresholds drive alerts.
- Pair with billing export to BigQuery (out of scope here) for cost attribution.

Validated via [live/60-finops](../../live/60-finops); see [../../tests](../../tests).
