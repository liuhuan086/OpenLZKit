# Example: account-factory

Validates the Alibaba Cloud account-factory module contract without real account
ids or credentials. It uses a placeholder folder id so `terraform validate` can
check the module shape locally; `plan` requires a sandbox management account.

```bash
terraform -chdir=examples/account-factory fmt -check -recursive
terraform -chdir=examples/account-factory init -backend=false
terraform -chdir=examples/account-factory validate
```
