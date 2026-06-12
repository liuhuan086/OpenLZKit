# Module: azure/subscription-vending

The Azure **multi-account (subscription) management** primitive: place existing
subscriptions into the management group hierarchy, and optionally create new
subscriptions under a billing scope.

## Responsibilities

- Associate existing subscriptions to management groups.
- Optionally create new subscriptions (alias) under an MCA/EA billing scope (off by default — billing impact).

It does **not**: build the management group hierarchy (see `modules/org`) or
configure in-subscription baselines (RBAC, network, logging).

## Usage

```hcl
module "subscriptions" {
  source = "../../modules/subscription-vending"

  associations = {
    corp_prod = {
      management_group_id = module.org.management_group_ids["landingzones/corp"]
      subscription_id     = "00000000-0000-0000-0000-000000000000"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `associations` | `map(object)` | `{}` | Existing subscriptions → management groups. |
| `subscriptions` | `map(object)` | `{}` | New subscriptions to create (alias + billing scope). Billing impact. |
| `common_tags` | `map(string)` | `{}` | Tags merged onto created subscriptions. |

## Outputs

| Name | Description |
|---|---|
| `subscription_ids` | Map of alias to created subscription id. |
| `associated_subscription_ids` | Map of association key to subscription id. |

## Security notes

- Subscription creation is opt-in and requires a billing scope; enable only with billing/ownership approvals.
- Placement into the right management group inherits its policy and RBAC guardrails.

Validated via [live/10-org](../../live/10-org); see [../../tests](../../tests).
