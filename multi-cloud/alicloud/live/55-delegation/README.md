# live/55-delegation (Alibaba Cloud)

Creates organization-level delegated administration and governed Resource Share
objects.

## What it does

- Registers Resource Directory delegated administrator accounts.
- Optionally delegates CloudSSO administration to a member account.
- Creates Resource Share objects for shared infrastructure resources.

## Static validation

```bash
terraform -chdir=live/55-delegation fmt -check -recursive
terraform -chdir=live/55-delegation init -backend=false
terraform -chdir=live/55-delegation validate
```

`plan`/`apply` require Resource Directory management-account permissions.
