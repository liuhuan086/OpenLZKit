# Azure tests

Static checks run locally without a subscription; `plan`/integration checks
require a sandbox subscription with the appropriate management group / RBAC.

## Static (no subscription) — CI gate

```bash
# format
terraform fmt -check -recursive

# validate every module and live stack (backend disabled)
terraform -chdir=live/00-bootstrap init -backend=false && terraform -chdir=live/00-bootstrap validate
terraform -chdir=live/10-org      init -backend=false && terraform -chdir=live/10-org      validate
terraform -chdir=live/20-identity init -backend=false && terraform -chdir=live/20-identity validate
terraform -chdir=live/40-security init -backend=false && terraform -chdir=live/40-security validate
```

## Plan / integration (sandbox subscription) — manual

```bash
# short-lived credentials via OIDC / az login
terraform -chdir=live/10-org plan -var subscription_id=<sub-guid>
```

## Coverage

| Target | fmt | validate | plan | notes |
|---|:--:|:--:|:--:|---|
| `live/00-bootstrap` | ✅ | ✅ | sub | local state → migrate to Azure Storage; OIDC CI identity |
| `modules/org` + `live/10-org` | ✅ | ✅ | sub | management group hierarchy |
| `modules/subscription-vending` | ✅ | ✅ | sub | subscription association/creation (off by default) |
| `modules/identity` + `live/20-identity` | ✅ | ✅ | sub | custom RBAC roles + assignments |
| `modules/policy-guardrails` + `live/40-security` | ✅ | ✅ | sub | Azure Policy deny guardrails |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
