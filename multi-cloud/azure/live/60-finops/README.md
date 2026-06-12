# live/60-finops (Azure)

Cost governance at the platform management group:

- A monthly **budget** with Actual (80%) and Forecasted (100%) threshold alerts.
- The built-in **Require a tag** policy enforcing the `owner` tag (via `policy-guardrails`).

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
  -var subscription_id=<sub-guid> \
  -var root_management_group_id=<mg-resource-id> \
  -var 'budget_contact_emails=["finops@example.com"]'
# apply after PR review + approval
```
