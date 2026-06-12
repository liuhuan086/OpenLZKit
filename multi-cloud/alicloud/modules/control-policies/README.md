# Module: alicloud/control-policies

Creates Alibaba Cloud Resource Directory control policies and attaches them to
organization targets.

## Responsibilities

- Create control policies from explicit JSON policy documents.
- Validate that each policy document is valid JSON before apply.
- Attach policies to Resource Directory targets by id.
- Tag policies with common governance metadata.

It does **not**:

- Enable Resource Directory.
- Decide target hierarchy — pass root or folder ids from `modules/org`.
- Replace runtime compliance checks such as Cloud Config.

## Preconditions

- Resource Directory is already enabled on the management account.
- Control Policy is enabled for the Resource Directory.
- Caller has ResourceManager permissions to create and attach control policies.

## Usage

```hcl
module "control_policies" {
  source = "../../modules/control-policies"

  name_prefix = "lz-"

  policies = {
    deny_disable_audit = {
      name         = "deny-disable-audit"
      description  = "Deny disabling organization audit controls."
      effect_scope = "RAM"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Deny"
          Action   = ["actiontrail:DeleteTrail", "actiontrail:StopLogging"]
          Resource = ["*"]
        }]
      })
    }
  }

  attachments = {
    root_audit_guardrail = {
      policy_key = "deny_disable_audit"
      target_id  = module.org.root_folder_id
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `""` | Prefix applied to every policy name. |
| `policies` | `map(object)` | `{}` | Control policies with JSON policy documents. |
| `attachments` | `map(object)` | `{}` | Policy attachments to Resource Directory target ids. |
| `common_tags` | `map(string)` | `{ managed_by = "terraform" }` | Tags merged onto every control policy. |

## Outputs

| Name | Description |
|---|---|
| `policy_ids` | Map of policy key to control policy id. |
| `attachment_ids` | Map of attachment key to attachment id. |

## Security notes

- Start with deny guardrails for high-risk operations: disabling ActionTrail,
  deleting log archives, creating long-lived AccessKeys, and using disallowed regions.
- Roll policies out to sandbox folders first, then expand to production folders.
- Keep policy documents small and reviewable; broad deny statements can block
  break-glass operations if not tested.

## Testing

Static checks (no cloud account required):

```bash
terraform -chdir=examples/control-policies fmt -check -recursive
terraform -chdir=examples/control-policies init -backend=false
terraform -chdir=examples/control-policies validate
```

`plan`/`apply` require management-account Resource Directory permissions.
