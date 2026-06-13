# live/60-finops (GCP)

Cost governance: a platform-wide Cloud Billing budget with 80% / 100% threshold
alerts. Label governance is enforced via `40-security` org policies and
`project-factory` common labels.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan -var project_id=<project> -var billing_account=<billing-account-id>
# apply after PR review + approval
```
