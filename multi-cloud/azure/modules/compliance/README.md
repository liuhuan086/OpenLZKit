# Module: azure/compliance

**Runtime compliance** (FP-7): Microsoft Defender for Cloud plans and an alert
contact. Complements plan-time Conftest policy and the deny guardrails in
`policy-guardrails`.

## Responsibilities

- Enable Defender for Cloud plans per resource type (`azurerm_security_center_subscription_pricing`).
- Configure the security alert contact (`azurerm_security_center_contact`).

It does **not**: define Azure Policy (see `modules/policy-guardrails`) or route
logs (see `modules/logging`).

## Usage

```hcl
module "compliance" {
  source = "../../modules/compliance"

  defender_plans = {
    StorageAccounts = { tier = "Standard" }
    KeyVaults       = { tier = "Standard" }
  }
  security_contact = { name = "lz-security", email = "secops@example.com" }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `defender_plans` | `map(object)` | `{}` | Plans keyed by resource type (`tier`/`subplan`). |
| `security_contact` | `object` | `null` | Alert contact (name, email, notifications). |

## Outputs

| Name | Description |
|---|---|
| `defender_plan_ids` | Map of resource type to pricing id. |

## Notes

- Defender plans are **per subscription** — apply this stack to each subscription (or via a subscription-scoped pipeline).
- Standard tiers incur cost; enable per workload risk and budget.

Validated via [live/45-compliance](../../live/45-compliance); see [../../tests](../../tests).
