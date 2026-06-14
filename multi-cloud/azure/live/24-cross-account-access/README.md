# live/24-cross-account-access (Azure)

Cross-subscription access (FP-4): a CI **deployer managed identity** federated to
GitHub Actions (no secret), granted least-privilege roles into target workload
subscriptions via `workload_role_assignments` (empty by default).

## State

```bash
terraform init \
  -backend-config="resource_group_name=lz-tfstate-rg" \
  -backend-config="storage_account_name=mylztfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="use_azuread_auth=true"
```

## Workflow

```bash
terraform validate
terraform plan -var subscription_id=<sub-guid> -var github_owner=example-org -var github_repo=openlzkit-example
# apply after PR review + approval; scope workload_role_assignments to specific subscriptions
```
