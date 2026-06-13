# Module: gcp/compliance

**Runtime compliance** (FP-7): Security Command Center findings export to
BigQuery and Pub/Sub notifications. Complements the plan-time Conftest gate and
the org-policy deny guardrails.

## Responsibilities

- Export SCC findings to BigQuery (`google_scc_organization_scc_big_query_export`).
- Stream findings to Pub/Sub (`google_scc_notification_config`).

It does **not**: enable SCC tiers/services, create the BigQuery dataset or Pub/Sub
topic (supply their ids), or define org policy (see `modules/org-policies`).

## Usage

```hcl
module "compliance" {
  source       = "../../modules/compliance"
  organization = "123456789012"

  bigquery_exports = {
    active-findings = { export_id = "lz-active-findings", dataset = "projects/sec/datasets/scc" }
  }
  notification_configs = {
    high-severity = { config_id = "lz-high", pubsub_topic = "projects/sec/topics/scc", filter = "severity=\"HIGH\"" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `organization` | `string` | — | Org id. |
| `bigquery_exports` | `map(object)` | `{}` | Findings exports to BigQuery (dataset, filter). |
| `notification_configs` | `map(object)` | `{}` | Pub/Sub notifications (topic, filter). |

## Outputs

| Name | Description |
|---|---|
| `bigquery_export_ids` | Map of export key to id. |
| `notification_config_ids` | Map of notification key to id. |

## Notes

- SCC is organization-scoped; deploy from the security project with org-level permissions.
- Pair high-severity notifications with on-call routing; export to BigQuery for trend analysis.

Validated via [live/45-compliance](../../live/45-compliance); see [../../tests](../../tests).
