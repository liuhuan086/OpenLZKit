# live/24-cross-account-access (Alibaba Cloud)

Creates target-account RAM roles and Resource Share definitions for approved
cross-account workflows.

## What it does

- Creates RAM roles trusted by explicit source-account principals.
- Attaches Alibaba system policies to those roles.
- Preserves optional STS trust conditions.
- Creates Resource Share definitions for shared infrastructure resources.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `cn-hangzhou` | Alibaba Cloud provider region. |
| `access_roles` | `map(object)` | `{}` | Cross-account RAM roles to create. |
| `resource_shares` | `map(object)` | `{}` | Resource Share definitions. |

## Static validation

```bash
terraform -chdir=live/24-cross-account-access fmt -check -recursive
terraform -chdir=live/24-cross-account-access init -backend=false
terraform -chdir=live/24-cross-account-access validate
```

`plan`/`apply` should run with target-account credentials.
