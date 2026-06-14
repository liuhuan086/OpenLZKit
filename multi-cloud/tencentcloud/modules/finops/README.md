# Module: tencentcloud/finops

Enables **cost-allocation tags** and (optionally) **cost budgets**. The allocation
tags are the FinOps attribution primitive; budgets are opt-in (Tencent budgets
require several bill/plan/period fields).

## Responsibilities

- Enable tag keys for cost allocation (`tencentcloud_billing_allocation_tag`).
- Create cost budgets with alert thresholds (`tencentcloud_billing_budget`).

It does **not**: enforce tag presence (use `control-policies`) or ship billing
data elsewhere.

## Usage

```hcl
module "finops" {
  source              = "../../modules/finops"
  allocation_tag_keys = ["owner", "cost_center", "env", "project"]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `allocation_tag_keys` | `list(string)` | `[]` | Tag keys enabled for cost allocation. |
| `budgets` | `map(object)` | `{}` | Budgets (bill/plan/period fields + warn thresholds). Opt-in. |

## Outputs

| Name | Description |
|---|---|
| `allocation_tag_keys` | Enabled cost-allocation tag keys. |
| `budget_ids` | Map of budget key to id. |

## Notes

- Enable the standard FinOps tag set (owner/cost_center/env/project) for attribution.
- Pair with a manage policy that requires tags so cost can always be attributed.

Validated via [live/60-finops](../../live/60-finops); see [../../tests](../../tests).
