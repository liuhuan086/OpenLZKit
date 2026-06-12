# live/20-identity (Azure)

Identity layer: least-privilege custom RBAC roles for platform personas
(`platform-operator`, `security-auditor`), defined and assignable at the
root/platform management group. Assignments to Entra groups are supplied per
environment via `role_assignments` (empty by default — principal ids are
environment-specific).

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
terraform plan -var subscription_id=<sub-guid> -var root_scope_id=<mg-resource-id>
# apply after PR review + approval
```
