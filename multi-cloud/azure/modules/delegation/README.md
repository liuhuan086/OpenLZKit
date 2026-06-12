# Module: azure/delegation

**Delegated management** (FP-8): Azure Lighthouse delegations granting a platform
(managing) tenant least-privilege cross-tenant access to a subscription/resource
group. The module **rejects the Owner role** via a precondition.

## Responsibilities

- Create `azurerm_lighthouse_definition` + `azurerm_lighthouse_assignment`.
- Enforce that no authorization grants the built-in Owner role.

It does **not**: create the managing-tenant principals, or share resources within
a tenant (use RBAC / `cross-account-access`).

## Usage

```hcl
module "delegation" {
  source = "../../modules/delegation"

  delegations = {
    platform-readonly = {
      name               = "platform-readonly"
      managing_tenant_id = var.managing_tenant_id
      scope              = "/subscriptions/..."
      authorizations = [
        { principal_id = var.ops_group_id, role_definition_id = "acdd72a7-3385-48ef-bd42-f606fba81ae7" }, # Reader
      ]
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on definition names. |
| `delegations` | `map(object)` | `{}` | Lighthouse delegations (scope, managing tenant, authorizations). |

## Outputs

| Name | Description |
|---|---|
| `lighthouse_definition_ids` | Map of delegation key to definition id. |
| `lighthouse_assignment_ids` | Map of delegation key to assignment id. |

## Security notes

- **Owner is rejected** — delegate only least-privilege built-in roles (Reader, specific operators).
- Scope each delegation to the smallest subscription/resource group; review managing-tenant principals.

Validated via [live/55-delegation](../../live/55-delegation); see [../../tests](../../tests).
