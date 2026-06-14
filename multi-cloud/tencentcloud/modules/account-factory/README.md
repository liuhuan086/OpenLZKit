# Module: tencentcloud/account-factory

The Tencent Cloud **multi-account management** primitive: create organization
member accounts into nodes with consistent tags.

## Responsibilities

- Create organization member accounts (`tencentcloud_organization_org_member`) under a node.

It does **not**: build the node hierarchy (see `modules/org`) or configure
in-account CAM/network/logging baselines.

## Usage

```hcl
module "accounts" {
  source = "../../modules/account-factory"

  members = {
    payment_prod = {
      name           = "payment-prod"
      node_id        = module.org.node_ids["workloads/prod"]
      permission_ids = [1, 2, 3]
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `members` | `map(object)` | `{}` | Members (name, node_id, policy_type, permission_ids). Billing impact. |
| `common_tags` | `map(string)` | `{}` | Tags merged onto every member. |

## Outputs

| Name | Description |
|---|---|
| `member_ids` | Map of member key to created member id (UIN). |

## Security notes

- Member creation is opt-in and has billing impact; enable with approvals.
- Placement into the right node inherits its manage-policy guardrails.

Validated via [live/10-org](../../live/10-org); see [../../tests](../../tests).
