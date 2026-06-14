# live/45-compliance (Tencent Cloud)

Runtime compliance (FP-7): a CSIP (Cloud Security Center) periodic risk scan
covering ports, weak passwords, PoC vulnerabilities and configuration risk.
Complements the plan-time Conftest gate and the manage-policy guardrails in
40-security; the audit trail is in 50-logging (CloudAudit).

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan
# requires CSIP enabled on the account; apply after PR review + approval
```
