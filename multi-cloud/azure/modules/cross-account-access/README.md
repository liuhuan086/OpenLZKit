# Module: azure/cross-account-access

**Cross-subscription access** (FP-4): user-assigned managed identities with
federated credentials (machine identities, no secrets) and least-privilege RBAC
role assignments at target scopes (other subscriptions/resources).

## Responsibilities

- Create user-assigned managed identities and their federated credentials (e.g. GitHub OIDC).
- Assign built-in/custom roles to machine or Entra principals at a target scope.

It does **not**: create Entra groups (supply object ids), define custom roles
(see `modules/identity`), or manage cross-tenant delegation (see `modules/delegation`).

## Usage

```hcl
module "cross_account" {
  source = "../../modules/cross-account-access"

  managed_identities = {
    cicd-deployer = {
      resource_group_name = azurerm_resource_group.identity.name
      location            = "eastus"
      federated_credentials = {
        main = { issuer = "https://token.actions.githubusercontent.com", subject = "repo:org/repo:ref:refs/heads/main" }
      }
    }
  }

  role_assignments = {
    deploy_prod = { scope = "/subscriptions/...", role_definition_name = "Contributor", managed_identity_key = "cicd-deployer" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on identity names. |
| `managed_identities` | `map(object)` | `{}` | Machine identities + federated credentials. |
| `role_assignments` | `map(object)` | `{}` | Target-scope RBAC (machine via `managed_identity_key` or `principal_id`). |

## Outputs

| Name | Description |
|---|---|
| `managed_identity_principal_ids` | Map of identity key to principal id. |
| `managed_identity_client_ids` | Map of identity key to client id. |
| `role_assignment_ids` | Map of assignment key to id. |

## Security notes

- Machine identities use federated credentials — no client secrets are stored.
- Scope assignments to the smallest target; prefer narrow built-in roles over Owner.
- Restrict federated `subject` to the specific repo/branch/environment.

Validated via [live/24-cross-account-access](../../live/24-cross-account-access); see [../../tests](../../tests).
