# Module: aws/identity-center

Creates IAM Identity Center permission sets, optional Identity Store groups and
users, and account assignments.

## Responsibilities

- Create permission sets with session duration, relay state and tags.
- Attach AWS managed policies to permission sets.
- Attach inline least-privilege policy documents to permission sets.
- Optionally create Identity Store groups, users and memberships.
- Assign permission sets to explicit account targets for group or user principals.

It does **not**:

- Enable IAM Identity Center.
- Synchronize an external IdP.
- Create AWS accounts or Organizations OUs.

## Usage

```hcl
module "identity_center" {
  source = "../../modules/identity-center"

  instance_arn      = "arn:aws:sso:::instance/ssoins-example"
  identity_store_id = "d-example"

  permission_sets = {
    security_audit = {
      name                = "SecurityAudit"
      managed_policy_arns = ["arn:aws:iam::aws:policy/SecurityAudit"]
    }
  }

  assignments = {
    security_audit_prod = {
      permission_set_key = "security_audit"
      principal_type     = "GROUP"
      principal_id       = "group-example"
      target_id          = "111122223333"
    }
  }
}
```

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/identity-center fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/identity-center init -backend=false
terraform -chdir=multi-cloud/aws/examples/identity-center validate
```
