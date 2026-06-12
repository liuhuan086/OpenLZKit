# Module: aws/department

Creates business department boundaries inside AWS Organizations.

## Responsibilities

- Create one OU per business department under an existing parent OU.
- Create one department administrator IAM role with explicit trusted principals.
- Attach reviewed AWS managed or customer managed IAM policies to the role.
- Attach reviewed Organizations policies to the department OU.
- Optionally create a department Tag Policy that pins owner, cost center,
  environment and data classification values.

It does **not**:

- Create member accounts; use `modules/account-factory`.
- Create global SCPs or Tag Policies; use `modules/org-policies`.
- Assign IAM Identity Center users or groups; use the future SSO module.

## Usage

```hcl
module "departments" {
  source = "../../modules/department"

  parent_ou_id = "ou-example-workloads"

  departments = {
    payments = {
      display_name           = "Payments"
      owner                  = "payments-platform"
      cost_center            = "cc-1001"
      trusted_principal_arns = ["arn:aws:iam::111122223333:role/platform-admin"]
      organization_policy_ids = [
        "p-example-deny-disable-audit",
      ]
    }
  }
}
```

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/departments fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/departments init -backend=false
terraform -chdir=multi-cloud/aws/examples/departments validate
```
