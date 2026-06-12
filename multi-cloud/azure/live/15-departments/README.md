# live/15-departments (Azure)

Business-department management (FP-3): one management group per department under
the Landing Zones group, each with its own admin RBAC scope and budget. Admin
principal ids and budgets are environment-specific.

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
terraform plan -var subscription_id=<sub-guid> -var parent_management_group_id=<landingzones-mg-id>
# apply after PR review + approval
```
