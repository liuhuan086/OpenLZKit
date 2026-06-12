# Module: azure/policy-guardrails

Organization **guardrails as Azure Policy** (the SCP-equivalent for Azure):
custom policy definitions + management-group-scope assignments.

## Responsibilities

- Create custom Azure Policy definitions (deny/audit rules) at a management group.
- Assign custom or built-in policies at management group scope.

It does **not**: create management groups (see `modules/org`) or run runtime
compliance scanning (see `modules/compliance`).

## Usage

```hcl
module "policy_guardrails" {
  source = "../../modules/policy-guardrails"

  policy_definitions = {
    allowed-locations = {
      display_name        = "Allowed locations"
      management_group_id = var.root_management_group_id
      policy_rule         = jsonencode({ if = { not = { field = "location", in = ["eastus"] } }, then = { effect = "deny" } })
    }
  }
  policy_assignments = {
    allowed-locations = {
      name                  = "lz-allowed-locations"
      management_group_id   = var.root_management_group_id
      policy_definition_key = "allowed-locations"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on custom policy names. |
| `policy_definitions` | `map(object)` | `{}` | Custom definitions (`policy_rule`/`parameters` are JSON). |
| `policy_assignments` | `map(object)` | `{}` | Assignments: custom (`policy_definition_key`) or built-in (`policy_definition_id`). |

## Outputs

| Name | Description |
|---|---|
| `policy_definition_ids` | Map of definition key to id. |
| `policy_assignment_ids` | Map of assignment key to id. |

## Security notes

- Prefer `deny` for hard guardrails; use `audit` where blocking would break legitimate workloads.
- Assign at the highest appropriate management group so child scopes inherit; roll out by group.

Validated via [live/40-security](../../live/40-security); see [../../tests](../../tests).
