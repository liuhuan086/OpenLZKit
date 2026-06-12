# live/00-bootstrap (Azure)

The one-time foundation every later stack depends on. Runs with **local state**,
then migrates its own state into the storage account it creates.

## What it creates

- **Resource group + storage account + blob container** for remote Terraform state —
  TLS1.2, HTTPS-only, no public blobs, shared-key disabled (Entra/OAuth auth),
  infrastructure encryption, blob versioning + soft delete.
- **GitHub Actions OIDC** — an Entra application + service principal + federated
  identity credential (no client secret), plus an optional plan-scoped role
  assignment.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `subscription_id` | `string` | — | Subscription hosting state/platform resources. |
| `location` | `string` | `eastus` | Region. |
| `state_resource_group_name` | `string` | `lz-tfstate-rg` | State resource group. |
| `state_storage_account_name` | `string` | — | Globally-unique storage account name. |
| `tfstate_container_name` | `string` | `tfstate` | Blob container. |
| `github_owner` / `github_repo` | `string` | — | Repo allowed to assume the CI identity. |
| `ci_role_definition_name` | `string` | `Reader` | Built-in role for CI (plan-only). |
| `ci_role_scope` | `string` | `null` | Scope for the CI role assignment (null skips). |
| `tags` | `map(string)` | `{}` | Tags. |

## Run

```bash
terraform init                  # local state
terraform validate              # static, no subscription
terraform apply \
  -var subscription_id=00000000-0000-0000-0000-000000000000 \
  -var state_storage_account_name=mylztfstate \
  -var github_owner=liuhuan086 -var github_repo=OpenLZKit

# then migrate state into the new storage account
terraform init -migrate-state \
  -backend-config="resource_group_name=lz-tfstate-rg" \
  -backend-config="storage_account_name=mylztfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=azure/00-bootstrap.tfstate" \
  -backend-config="use_azuread_auth=true"
```

## Security notes

- CI uses OIDC federation; no client secret is created or stored.
- Scope `ci_role_scope` to the smallest subscription/management group; use a
  higher-privilege apply identity only with environment protection.
- The state storage account disables shared keys and public blob access.
