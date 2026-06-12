# Module: aws/finops

Builds AWS FinOps controls for budgets, anomaly detection and cost allocation.

## Responsibilities

- Create AWS Budgets with notifications.
- Create Cost Anomaly Detection monitors and subscriptions.
- Create Cost Categories for department, account or environment allocation.

It does **not**:

- Create Organizations Tag Policies; those live in `modules/org-policies` and
  `modules/department`.
- Replace billing account approval workflows.
- Create dashboards or exports.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/finops fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/finops init -backend=false
terraform -chdir=multi-cloud/aws/examples/finops validate
```
