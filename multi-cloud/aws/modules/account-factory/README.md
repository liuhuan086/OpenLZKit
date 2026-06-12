# Module: aws/account-factory

Creates AWS Organizations member accounts from a standard account vending
contract.

## Responsibilities

- Create accounts under existing OUs.
- Enforce account governance tags before creation.
- Keep account creation opt-in through `accounts = {}` by default.

It does **not**:

- Create OUs — use `modules/org`.
- Configure account baselines after creation.
- Replace Control Tower Account Factory or AFT in production environments.

## Usage

```hcl
module "accounts" {
  source = "../../modules/account-factory"

  ou_ids = module.org.ou_ids

  accounts = {
    payment_dev = {
      name   = "payment-dev"
      email  = "aws-payment-dev@example.com"
      ou_key = "workloads/dev"
      tags = {
        owner               = "payments-platform"
        cost_center         = "cc-1001"
        env                 = "dev"
        project             = "payment"
        data_classification = "internal"
      }
    }
  }
}
```

## Security notes

- Account creation is intentionally opt-in and should be gated by approval.
- Do not commit real emails or account ids in examples.
- Use sandbox organizations for `plan`/`apply` tests.
