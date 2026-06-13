# live/24-cross-account-access (GCP)

Cross-project access (FP-4): a CI **deployer service account** impersonated by the
repo's federated identity (Workload Identity Federation, no key), granted
least-privilege cross-project roles via `project_bindings` (empty by default).

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan \
  -var project_id=<automation-project> \
  -var workload_identity_pool_name=<pool-name-from-bootstrap> \
  -var github_owner=liuhuan086 -var github_repo=OpenLZKit
# apply after PR review + approval; scope project_bindings to specific projects
```
