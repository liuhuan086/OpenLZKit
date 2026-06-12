# Live: AWS bootstrap

Bootstraps the resources needed before the rest of the AWS landing zone can use
remote Terraform state and CI/CD automation.

## Responsibilities

- Create an optional S3 bucket for Terraform remote state with versioning,
  server-side encryption and public access blocks.
- Create an optional DynamoDB lock table.
- Create an optional customer managed KMS key for state encryption.
- Create an optional CI/CD bootstrap IAM role.

It does **not**:

- Configure backend blocks in the other live stacks automatically.
- Create AWS Organizations, accounts or Identity Center resources.
- Replace a formal production change approval for the initial bootstrap apply.

## Testing

```bash
terraform -chdir=multi-cloud/aws/live/00-bootstrap fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/00-bootstrap init -backend=false
terraform -chdir=multi-cloud/aws/live/00-bootstrap validate
```
