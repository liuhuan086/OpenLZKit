# live/70-workload-onboarding (GCP)

Template for onboarding a new workload: a workload service account and optional
scoped team access, with the standard FinOps label set output for the project.
Copy the module block per workload/environment.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan -var workload_project_id=<workload-project> -var team_member=group:payment@example.com
# apply after PR review + approval
```
