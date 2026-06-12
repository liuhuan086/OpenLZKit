# Module: aws/workload-onboarding

Standardizes workload onboarding into an AWS landing zone.

## Responsibilities

- Produce the standard owner, department, cost center, environment and data
  classification tags for each workload.
- Create optional workload access roles for platform, CI/CD or operations
  principals.
- Attach managed and inline IAM policies to those workload access roles.
- Write onboarding metadata into SSM Parameter Store for handoff and audit.

It does **not**:

- Create AWS accounts; use `modules/account-factory`.
- Create VPCs, subnets or Transit Gateway attachments; use `modules/network`
  and `modules/connectivity`.
- Create IAM Identity Center permission sets or assignments; use
  `modules/identity-center`.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/workload-onboarding fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/workload-onboarding init -backend=false
terraform -chdir=multi-cloud/aws/examples/workload-onboarding validate
```
