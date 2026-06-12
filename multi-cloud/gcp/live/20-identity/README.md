# live/20-identity (GCP)

Identity layer: least-privilege custom org roles for platform personas
(`lzPlatformOperator`, `lzSecurityAuditor`). Bindings to Cloud Identity groups
are supplied per environment via `folder_bindings` (empty by default — members
are environment-specific).

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan -var project_id=<seed-project> -var org_id=<org-number>
# apply after PR review + approval
```
