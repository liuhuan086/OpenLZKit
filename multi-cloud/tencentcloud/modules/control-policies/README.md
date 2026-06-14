# Module: tencentcloud/control-policies

Organization **guardrails as manage policies** (the SCP-equivalent for Tencent
Cloud): create manage policies and attach them at node/member scope.

## Responsibilities

- Create organization manage policies (deny rules).
- Attach policies to organization nodes or members.

It does **not**: create nodes/members (see `modules/org` / `account-factory`) or
run runtime detection (see `modules/compliance`).

## Usage

```hcl
module "control_policies" {
  source = "../../modules/control-policies"

  policies = {
    deny-disable-audit = {
      content = jsonencode({ version = "2.0", statement = [{ effect = "deny", action = ["cloudaudit:DeleteAuditTrack"], resource = ["*"] }] })
    }
  }
  attachments = {
    deny-disable-audit = { policy_key = "deny-disable-audit", target_id = 2001, target_type = "NODE" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on policy names. |
| `policies` | `map(object)` | `{}` | Manage policies (content JSON, type). |
| `attachments` | `map(object)` | `{}` | Attach (policy_key, target_id, target_type NODE/MEMBER). |

## Outputs

| Name | Description |
|---|---|
| `policy_ids` | Map of policy key to id. |

## Security notes

- Attach at the highest appropriate node so members inherit; roll out by node where risky.
- Recommended baseline: deny disabling CloudAudit, deny leaving the organization, restrict regions.

Validated via [live/40-security](../../live/40-security); see [../../tests](../../tests).
