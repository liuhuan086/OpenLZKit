# Example: compliance

Validates the Alibaba Cloud compliance module contract without real account ids
or credentials. Placeholder folder ids and delivery ARNs let `terraform validate`
check Cloud Config wiring locally; `plan` requires a sandbox compliance account.

```bash
terraform -chdir=examples/compliance fmt -check -recursive
terraform -chdir=examples/compliance init -backend=false
terraform -chdir=examples/compliance validate
```
