# live/40-security (GCP)

Organization guardrails as Organization Policy (FP-2), applied at the org:

- Disable service-account key creation, skip default network, require OS Login, enforce uniform bucket access.
- Restrict resource locations (US/EU), deny external VM IPs.

Folders and projects inherit these constraints.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan -var project_id=<seed-project> -var org_id=<org-number>
# apply after PR review + approval; org policies change the surface of all child resources
```
