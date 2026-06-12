# Module: aws/cross-account-access

Creates standard cross-account access paths for AWS Landing Zone accounts.

## Responsibilities

- Create target-account IAM roles for STS AssumeRole.
- Support explicit AWS principals, OIDC federated principals and generated OIDC providers.
- Support ExternalId and additional trust policy conditions.
- Attach managed policies and inline least-privilege policy documents.
- Create AWS RAM resource shares with principal and resource associations.

It does **not**:

- Create the source or target accounts.
- Assign IAM Identity Center users or groups.
- Create the shared resources themselves.

## Usage

```hcl
module "cross_account_access" {
  source = "../../modules/cross-account-access"

  access_roles = {
    security_audit = {
      role_name              = "security-audit"
      trusted_principal_arns = ["arn:aws:iam::111122223333:root"]
      external_id            = "security-audit"
      managed_policy_arns    = ["arn:aws:iam::aws:policy/SecurityAudit"]
    }
  }
}
```

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/cross-account-access fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/cross-account-access init -backend=false
terraform -chdir=multi-cloud/aws/examples/cross-account-access validate
```
