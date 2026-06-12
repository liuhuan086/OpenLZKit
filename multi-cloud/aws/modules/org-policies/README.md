# Module: aws/org-policies

Creates AWS Organizations Service Control Policies and Tag Policies, then
attaches them to root, OU or account targets.

## Responsibilities

- Create `SERVICE_CONTROL_POLICY` and `TAG_POLICY` documents.
- Validate policy content is JSON before provider schema validation.
- Attach policies to explicit AWS Organizations targets.
- Expose policy ids and attachment ids for audit and downstream documentation.

It does **not**:

- Generate every enterprise guardrail automatically.
- Replace AWS Control Tower controls.
- Configure runtime detection services such as Config, Security Hub or GuardDuty.

## Usage

```hcl
module "org_policies" {
  source = "../../modules/org-policies"

  policies = {
    deny_disable_audit = {
      name = "deny-disable-audit"
      type = "SERVICE_CONTROL_POLICY"
      content = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid      = "DenyDisableAudit"
          Effect   = "Deny"
          Action   = ["cloudtrail:StopLogging", "config:StopConfigurationRecorder"]
          Resource = "*"
        }]
      })
    }
  }

  attachments = {
    root_audit = {
      policy_key = "deny_disable_audit"
      target_id  = "r-example"
    }
  }
}
```

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/org-policies fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/org-policies init -backend=false
terraform -chdir=multi-cloud/aws/examples/org-policies validate
```
