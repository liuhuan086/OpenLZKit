# Module: aws/finops

Builds AWS FinOps controls for budgets, anomaly detection, cost allocation and
Cost and Usage Report exports.

## Responsibilities

- Create AWS Budgets with notifications.
- Create Cost Anomaly Detection monitors and subscriptions.
- Create Cost Categories for department, account or environment allocation.
- Create optional Cost and Usage Report definitions.
- Create optional hardened S3 buckets for CUR delivery.
- Create optional QuickSight Athena data sources, folders and groups for BI handoff.

It does **not**:

- Create Organizations Tag Policies; those live in `modules/org-policies` and
  `modules/department`.
- Replace billing account approval workflows.
- Create finished dashboards or analyses.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/finops fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/finops init -backend=false
terraform -chdir=multi-cloud/aws/examples/finops validate
```
