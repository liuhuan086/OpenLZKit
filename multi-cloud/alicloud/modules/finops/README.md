# Module: alicloud/finops

Enforces the Landing Zone **FinOps tag governance** via an Alibaba **tag policy**:
every resource must carry the standard cost-attribution tag set.

## Responsibilities

- `alicloud_tag_policy` — requires the FinOps tag keys (`owner`, `cost_center`, `env`, `project`, `managed_by`, `data_classification`).
- `alicloud_tag_policy_attachment` — optionally attach to the Resource Directory root/folder/account.

It does **not** create budgets (Alibaba budget alerts are configured outside
Terraform) — pair this with cost reports and the tag spec in
[docs/design/12](../../../../docs/design/12-finops-cost-governance.md).

## Usage

```hcl
module "finops" {
  source           = "../../modules/finops"
  attach_target_id = "rd-xxxxxx" # RD root id; omit to create the policy only
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `policy_name` | `string` | `"lz-required-tags"` | Tag policy name. |
| `required_tag_keys` | `list(string)` | FinOps tag set | Keys every resource must carry. |
| `attach_target_id` | `string` | `null` | RD target to attach to (null = create only). |
| `attach_target_type` | `string` | `"Root"` | `Root` / `Folder` / `Account`. |

## Outputs

| Name | Description |
|---|---|
| `policy_id` | Created tag policy id. |
| `required_tag_keys` | Enforced tag keys. |

## Security / governance notes

- Tag policy enforcement is Resource-Directory-wide once attached; roll out from a folder first.
- Combine with policy-as-code (plan-time) so missing tags fail CI before apply.

Validated via [live/60-finops](../../live/60-finops); see [../../tests](../../tests).
