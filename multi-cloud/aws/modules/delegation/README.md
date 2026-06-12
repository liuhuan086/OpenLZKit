# Module: aws/delegation

Configures AWS Organizations delegated administrators and governed AWS RAM
resource sharing.

## Responsibilities

- Register delegated administrators for precise AWS service principals.
- Optionally enable AWS RAM sharing with AWS Organizations.
- Create AWS RAM resource shares.
- Associate RAM principals, resources and permissions with each share.

It does **not**:

- Configure service-specific settings after delegation.
- Create the resources being shared.
- Replace cross-account IAM roles or Transit Gateway routing modules.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/delegation fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/delegation init -backend=false
terraform -chdir=multi-cloud/aws/examples/delegation validate
```
