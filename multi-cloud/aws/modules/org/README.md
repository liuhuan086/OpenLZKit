# Module: aws/org

Builds the AWS Organizations OU hierarchy for the Landing Zone organization
layer.

## Responsibilities

- Read the existing AWS Organizations root.
- Create a one- or two-level OU hierarchy.
- Expose stable OU ids for account vending and policy attachment.

It does **not**:

- Create member accounts — use `modules/account-factory`.
- Enable AWS Organizations or Control Tower.
- Manage SCPs, IAM, logging, network or FinOps controls.

## Usage

```hcl
module "org" {
  source = "../../modules/org"

  name_prefix = "lz-"

  organizational_units = {
    security = {
      name = "Security"
      children = {
        log-archive      = { name = "Log Archive" }
        security-tooling = { name = "Security Tooling" }
      }
    }
    workloads = {
      name = "Workloads"
      children = {
        prod = { name = "Prod" }
        dev  = { name = "Dev" }
      }
    }
  }
}
```

## Testing

```bash
terraform -chdir=examples/basic fmt -check -recursive
terraform -chdir=examples/basic init -backend=false
terraform -chdir=examples/basic validate
```
