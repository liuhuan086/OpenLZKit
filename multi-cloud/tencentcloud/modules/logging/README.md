# Module: tencentcloud/logging

Stands up **central audit logging**: a CLS logset + topic and a CloudAudit track
delivering management events to it.

## Responsibilities

- Create a CLS logset and topic (retention) as the central audit sink.
- Create a CloudAudit track (all regions, organization-wide) → CLS.

It does **not**: configure CSIP risk center (see `modules/compliance`) or per-
service log shipping.

## Usage

```hcl
module "logging" {
  source = "../../modules/logging"
  region = "ap-guangzhou"
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `region` | `string` | — | Region of the CLS topic / audit storage. |
| `logset_name` / `topic_name` | `string` | `central-audit` / `cloudaudit` | CLS names. |
| `period` | `number` | `365` | Topic retention (days). |
| `audit_action_type` | `string` | `Write` | CloudAudit action type (Read/Write). |
| `track_for_all_members` | `bool` | `true` | Capture all organization members. |
| `tags` | `map(string)` | `{}` | Tags. |

## Outputs

| Name | Description |
|---|---|
| `logset_id` | CLS logset id. |
| `topic_id` | CLS topic id. |
| `audit_track_id` | CloudAudit track id. |

## Security notes

- Deploy in a dedicated audit-log account; restrict CLS access to auditors.
- Set retention to your compliance requirement; add a Read track for full coverage if needed.

Validated via [live/50-logging](../../live/50-logging); see [../../tests](../../tests).
