# live/50-logging (Azure)

Central audit: a Log Analytics workspace in the management/logging subscription.
Resource diagnostic settings are attached per environment via the module's
`diagnostic_settings` input.

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
terraform plan -var subscription_id=<logging-sub-guid>
# apply after PR review + approval
```
