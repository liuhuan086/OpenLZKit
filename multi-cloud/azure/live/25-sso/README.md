# live/25-sso (Azure)

Human access (FP-5): Entra ID security groups (`platform-admins`,
`security-auditors`) granted Contributor/Reader at the platform management group.
Membership is managed via the IdP; groups receive RBAC, not users. Gate
high-privilege groups behind PIM.

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
# requires Entra directory permissions to create groups; apply after PR review + approval
```
