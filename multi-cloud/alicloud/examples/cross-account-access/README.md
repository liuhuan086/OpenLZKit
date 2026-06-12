# Example: cross-account-access

Validates the Alibaba Cloud cross-account-access module contract without real
account ids or credentials. It uses placeholder principals and resource ARNs so
`terraform validate` can check the module shape locally; `plan` requires a
sandbox target account.

```bash
terraform -chdir=examples/cross-account-access fmt -check -recursive
terraform -chdir=examples/cross-account-access init -backend=false
terraform -chdir=examples/cross-account-access validate
```
