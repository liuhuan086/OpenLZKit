# live/40-security (Azure)

Organization guardrails as Azure Policy (FP-2), assigned at the platform root
management group:

- **Allowed locations** — deny resources outside approved regions.
- **Deny public blob access** — storage accounts must disable public blob access.

Child management groups and subscriptions inherit these denies.

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
terraform plan -var subscription_id=<sub-guid> -var root_management_group_id=<mg-resource-id>
# apply after PR review + approval; deny policies change the permission surface of all child scopes
```
