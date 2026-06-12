# Module: aws/compliance

Builds runtime compliance and detective controls for AWS Landing Zone accounts.

## Responsibilities

- Enable Security Hub in the current account.
- Register a Security Hub organization admin account.
- Subscribe to Security Hub standards.
- Enable GuardDuty in the current account.
- Register a GuardDuty organization admin account.
- Create AWS Config organization aggregators.
- Create AWS Config managed rules and conformance packs.

It does **not**:

- Create S3 buckets, KMS keys or delivery channels for Config recordings.
- Replace SCP guardrails from `modules/org-policies`.
- Configure all delegated administrator services; that is handled by the future
  delegation module.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/compliance fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/compliance init -backend=false
terraform -chdir=multi-cloud/aws/examples/compliance validate
```
