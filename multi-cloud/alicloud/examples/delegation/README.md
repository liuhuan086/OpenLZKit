# Example: delegation

Validates the Alibaba Cloud delegation module contract without real account ids
or credentials. Placeholder account ids and ARNs let `terraform validate` check
the module shape locally; `plan` requires a sandbox management account.

```bash
terraform -chdir=examples/delegation fmt -check -recursive
terraform -chdir=examples/delegation init -backend=false
terraform -chdir=examples/delegation validate
```
