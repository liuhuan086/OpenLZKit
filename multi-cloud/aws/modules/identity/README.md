# Module: aws/identity

Builds the member-account IAM baseline that complements IAM Identity Center.

## Responsibilities

- Manage an optional IAM account alias for readable account identification.
- Manage the account password policy for emergency IAM users when required.
- Create customer managed IAM policies.
- Create permission boundary policies and expose their ARNs to workload modules.

It does **not**:

- Create IAM users or long-lived access keys.
- Create IAM Identity Center permission sets or assignments; use
  `modules/identity-center`.
- Create cross-account machine roles; use `modules/cross-account-access`.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/identity fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/identity init -backend=false
terraform -chdir=multi-cloud/aws/examples/identity validate
```
