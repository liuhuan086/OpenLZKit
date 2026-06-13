# live/45-compliance (GCP)

Runtime compliance (FP-7): Security Command Center findings export to BigQuery
and a high-severity Pub/Sub notification. Complements the plan-time Conftest gate
and the org-policy guardrails in 40-security.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan \
  -var project_id=<security-project> \
  -var org_id=<org-number> \
  -var findings_dataset=projects/<p>/datasets/<d> \
  -var findings_topic=projects/<p>/topics/<t>
# requires org-level SCC permissions; apply after PR review + approval
```
