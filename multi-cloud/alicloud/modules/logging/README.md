# Module: alicloud/logging

Stands up **central audit logging**: an SLS project + logstore and an ActionTrail
trail that delivers management events into it.

## Responsibilities

- `alicloud_log_project` / `alicloud_log_store` — the central audit destination, with retention.
- `alicloud_actiontrail_trail` — organization trail (all regions, read+write events) → SLS.

It does **not**: manage VPC flow logs, application logs, alerting, or the log
archive account boundary (that lives in the account model). Deploy this in the
dedicated audit-log account.

## Usage

```hcl
module "logging" {
  source             = "../../modules/logging"
  region             = "cn-hangzhou"
  audit_project_name = "my-lz-audit"
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `region` | `string` | — | Region of the SLS project (builds the ActionTrail ARN). |
| `audit_project_name` | `string` | — | Globally-unique SLS project name. |
| `audit_logstore_name` | `string` | `"actiontrail"` | Logstore name. |
| `retention_period` | `number` | `365` | Logstore retention (days). |
| `is_organization_trail` | `bool` | `true` | Multi-account org trail (needs RD management account). |
| `tags` | `map(string)` | `{}` | Tags on the SLS project. |

## Outputs

| Name | Description |
|---|---|
| `audit_project_name` | SLS project name. |
| `audit_logstore_name` | SLS logstore name. |
| `trail_name` | ActionTrail trail name. |

## Security notes

- Operation audit is on by default (`event_rw = All`, all regions).
- Set retention to your compliance requirement; consider an OSS archive + delete protection.
- Apply requires the ActionTrail service-linked role to write to SLS.

Validated via [live/50-logging](../../live/50-logging); see [../../tests](../../tests).
