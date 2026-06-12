# live/45-compliance (Azure)

Runtime compliance (FP-7): Microsoft Defender for Cloud plans (VMs, Storage,
Key Vaults, Containers, ARM) and an alert contact. Apply **per subscription**.
Complements the plan-time Conftest gate and the deny guardrails in 40-security.

## State

```bash
terraform init \
  -backend-config="resource_group_name=lz-tfstate-rg" \
  -backend-config="storage_account_name=mylztfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="use_azuread_auth=true"
```

## Workflow

```bash
terraform validate
terraform plan -var subscription_id=<sub-guid> -var security_contact_email=secops@example.com
# apply after PR review + approval; Standard tiers incur cost
```
