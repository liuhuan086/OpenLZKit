# Example: AWS IAM account baseline

Shows the account-local IAM baseline that complements IAM Identity Center:
account alias, emergency password policy, permission boundaries and customer
managed policies.

```bash
terraform -chdir=multi-cloud/aws/examples/identity init -backend=false
terraform -chdir=multi-cloud/aws/examples/identity validate
```
