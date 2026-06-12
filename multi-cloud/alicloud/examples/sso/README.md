# Example: sso

Validates the Alibaba Cloud CloudSSO module contract without real account ids or
credentials. It uses placeholder target account ids so `terraform validate` can
check the module shape locally; `plan` requires CloudSSO administrative
permissions.

```bash
terraform -chdir=examples/sso fmt -check -recursive
terraform -chdir=examples/sso init -backend=false
terraform -chdir=examples/sso validate
```
