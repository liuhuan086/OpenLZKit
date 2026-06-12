# Example: departments

Validates the Alibaba Cloud department module contract without real account ids
or credentials. It uses placeholder folder and policy ids so `terraform validate`
can check the module shape locally; `plan` requires a sandbox management account.

```bash
terraform -chdir=examples/departments fmt -check -recursive
terraform -chdir=examples/departments init -backend=false
terraform -chdir=examples/departments validate
```
