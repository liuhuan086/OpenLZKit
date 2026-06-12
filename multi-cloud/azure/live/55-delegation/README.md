# live/55-delegation (Azure)

Delegated management (FP-8): an Azure Lighthouse delegation granting the platform
tenant **Reader** on the delegated subscription. The module rejects Owner grants.

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
terraform plan \
  -var subscription_id=<delegated-sub-guid> \
  -var managing_tenant_id=<platform-tenant-guid> \
  -var delegated_scope=/subscriptions/<delegated-sub-guid> \
  -var ops_principal_id=<managing-tenant-group-object-id>
# apply after PR review + approval
```
