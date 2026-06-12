# live/25-sso (Alibaba Cloud)

Creates CloudSSO human-access primitives after organization and cross-account
boundaries exist.

## What it does

- Creates or reuses a CloudSSO directory.
- Creates groups.
- Creates access configurations.
- Assigns groups/users/principal ids to accounts.
- Optionally provisions access configurations to accounts.

## Static validation

```bash
terraform -chdir=live/25-sso fmt -check -recursive
terraform -chdir=live/25-sso init -backend=false
terraform -chdir=live/25-sso validate
```

`plan`/`apply` require CloudSSO administrative permissions.
