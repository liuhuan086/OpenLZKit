# Example: connectivity

Validates the Alibaba Cloud connectivity module contract without real account ids
or credentials. Placeholder VPC, vSwitch and account ids let `terraform validate`
check CEN / Transit Router wiring locally; `plan` requires a sandbox network
account.

```bash
terraform -chdir=examples/connectivity fmt -check -recursive
terraform -chdir=examples/connectivity init -backend=false
terraform -chdir=examples/connectivity validate
```
