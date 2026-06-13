# Module: gcp/logging

Stands up the **central log archive** (GCS bucket) and **aggregated folder log
sinks** that route logs to it across all child resources.

## Responsibilities

- Create a hardened log-archive bucket (versioned, uniform access, public access
  prevention, retention policy).
- Create aggregated folder sinks (`include_children`) and grant each sink's writer
  identity write access to the bucket.

It does **not**: configure Security Command Center (see `modules/compliance`) or
per-project bucket configs / BigQuery datasets.

## Usage

```hcl
module "logging" {
  source          = "../../modules/logging"
  project         = var.logging_project_id
  log_bucket_name = "my-lz-log-archive"

  sinks = {
    org-audit = { parent = "folders/111", filter = "logName:\"cloudaudit.googleapis.com\"" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `project` | `string` | — | Logging project for the archive bucket. |
| `log_bucket_name` | `string` | — | Globally-unique archive bucket name. |
| `location` | `string` | `US` | Bucket location. |
| `retention_days` | `number` | `365` | Bucket retention policy. |
| `lock_retention` | `bool` | `false` | Lock retention (Bucket Lock) — **irreversible**; enable in production. |
| `sinks` | `map(object)` | `{}` | Aggregated folder sinks (`parent`, `filter`, `include_children`). |

## Outputs

| Name | Description |
|---|---|
| `log_bucket` | Central log-archive bucket name. |
| `sink_writer_identities` | Map of sink key to writer identity. |

## Security notes

- Centralize logs in a dedicated logging project; the bucket enforces public access prevention and retention.
- Aggregated sinks with `include_children` capture all descendant projects' logs.

Validated via [live/50-logging](../../live/50-logging); see [../../tests](../../tests).
