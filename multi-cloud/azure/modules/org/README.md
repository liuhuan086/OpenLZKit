# Module: azure/org

Builds the Azure **management group hierarchy** for the Landing Zone
organization layer.

## Responsibilities

- Create a one- or two-level management group hierarchy with a consistent name prefix.
- Expose management group ids for placing subscriptions and assigning policy/RBAC.

It does **not**: create or move subscriptions (see `modules/subscription-vending`),
assign Azure Policy (see `modules/policy-guardrails`), or grant RBAC.

## Usage

```hcl
module "org" {
  source      = "../../modules/org"
  name_prefix = "lz-"

  management_groups = {
    platform = {
      display_name = "Platform"
      children = {
        identity     = { display_name = "Identity" }
        connectivity = { display_name = "Connectivity" }
      }
    }
    sandbox = { display_name = "Sandbox" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on every management group name (immutable id). |
| `parent_management_group_id` | `string` | `null` | Parent MG resource id; null = tenant root group. |
| `management_groups` | `map(object)` | — | Hierarchy: `display_name` + one optional `children` level. |

## Outputs

| Name | Description |
|---|---|
| `management_group_ids` | Map of key (top-level and `<parent>/<child>`) to MG resource id. |
| `management_group_names` | Map of key to MG name (immutable id). |

## Security notes

- Management groups are tenant-global; this module is region-independent.
- Caller needs Management Group Contributor (and tenant-root access for top-level groups).

Validated via [live/10-org](../../live/10-org); see [../../tests](../../tests).
