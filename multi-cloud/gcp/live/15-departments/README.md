# live/15-departments (GCP)

Business-department management (FP-3): one folder per department under the
Workloads folder, each with its own admin IAM scope and budget. Admin members and
budgets are environment-specific.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan -var project_id=<project> -var parent_folder=folders/<workloads-folder-id>
# apply after PR review + approval
```
