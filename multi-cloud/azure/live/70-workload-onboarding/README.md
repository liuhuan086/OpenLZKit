# live/70-workload-onboarding (Azure)

Template for onboarding a new workload: an isolated resource group, a workload
managed identity, and optional scoped team access, tagged with the standard
FinOps tag set. Copy the module block per workload/environment.

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
terraform plan -var subscription_id=<workload-sub-guid> -var team_principal_id=<entra-group-id>
# apply after PR review + approval
```
