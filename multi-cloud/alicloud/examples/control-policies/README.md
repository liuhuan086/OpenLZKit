# Example: control-policies

Validates the Alibaba Cloud control-policies module contract without real
account ids or credentials. It uses a placeholder target id so
`terraform validate` can check the module shape locally; `plan` requires a
sandbox management account.

```bash
terraform -chdir=examples/control-policies fmt -check -recursive
terraform -chdir=examples/control-policies init -backend=false
terraform -chdir=examples/control-policies validate
```
