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
terraform -chdir=live/15-departments init -backend=false && terraform -chdir=live/15-departments validate
terraform -chdir=live/20-identity init -backend=false && terraform -chdir=live/20-identity validate
terraform -chdir=live/24-cross-account-access init -backend=false && terraform -chdir=live/24-cross-account-access validate
terraform -chdir=live/25-sso init -backend=false && terraform -chdir=live/25-sso validate
terraform -chdir=live/30-network  init -backend=false && terraform -chdir=live/30-network  validate
terraform -chdir=live/35-connectivity init -backend=false && terraform -chdir=live/35-connectivity validate
terraform -chdir=live/40-security init -backend=false && terraform -chdir=live/40-security validate
terraform -chdir=live/45-compliance init -backend=false && terraform -chdir=live/45-compliance validate
terraform -chdir=live/50-logging  init -backend=false && terraform -chdir=live/50-logging  validate
terraform -chdir=live/55-delegation init -backend=false && terraform -chdir=live/55-delegation validate
terraform -chdir=live/60-finops   init -backend=false && terraform -chdir=live/60-finops   validate
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
| `modules/department` + `live/15-departments` | ✅ | ✅ | sub | department MG + RBAC + budget |
| `modules/identity` + `live/20-identity` | ✅ | ✅ | sub | custom RBAC roles + assignments |
| `modules/cross-account-access` + `live/24-cross-account-access` | ✅ | ✅ | sub | managed identity federation + cross-sub RBAC |
| `modules/entra-access` + `live/25-sso` | ✅ | ✅ | sub | Entra groups + RBAC |
| `modules/network` + `live/30-network` | ✅ | ✅ | sub | Hub-Spoke VNets; default-deny NSG |
| `modules/connectivity` + `live/35-connectivity` | ✅ | ✅ | sub | hub-spoke VNet peering |
| `modules/policy-guardrails` + `live/40-security` | ✅ | ✅ | sub | Azure Policy deny guardrails |
| `modules/compliance` + `live/45-compliance` | ✅ | ✅ | sub | Defender for Cloud plans |
| `modules/logging` + `live/50-logging` | ✅ | ✅ | sub | central Log Analytics + diagnostics |
| `modules/delegation` + `live/55-delegation` | ✅ | ✅ | sub | Azure Lighthouse delegation (no Owner) |
| `modules/finops` + `live/60-finops` | ✅ | ✅ | sub | MG budgets + require-tag policy |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
