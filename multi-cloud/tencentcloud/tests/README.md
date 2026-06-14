# Tencent Cloud tests

Static checks run locally without an account; `plan`/integration checks require a
sandbox organization/account with the appropriate CAM permissions.

## Static (no account) — CI gate

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
terraform -chdir=live/70-workload-onboarding init -backend=false && terraform -chdir=live/70-workload-onboarding validate
```

## Plan / integration (sandbox account) — manual

```bash
# short-lived credentials via STS / role assumption
terraform -chdir=live/10-org plan -var root_node_id=<root-node-id>
```

## Coverage

| Target | fmt | validate | plan | notes |
|---|:--:|:--:|:--:|---|
| `live/00-bootstrap` | ✅ | ✅ | account | local state → migrate to COS; CAM CI role |
| `modules/org` + `live/10-org` | ✅ | ✅ | account | organization node hierarchy |
| `modules/account-factory` | ✅ | ✅ | account | member-account vending (off by default) |
| `modules/department` + `live/15-departments` | ✅ | ✅ | account | department node + role + policy |
| `modules/identity` + `live/20-identity` | ✅ | ✅ | account | CAM policies + roles |
| `modules/cross-account-access` + `live/24-cross-account-access` | ✅ | ✅ | account | cross-account CAM roles |
| `modules/identity-groups` + `live/25-sso` | ✅ | ✅ | account | CAM groups + policies |
| `modules/network` + `live/30-network` | ✅ | ✅ | account | Hub-Spoke VPCs; default-deny SG |
| `modules/connectivity` + `live/35-connectivity` | ✅ | ✅ | account | CCN + VPC attachment |
| `modules/control-policies` + `live/40-security` | ✅ | ✅ | account | org manage-policy guardrails |
| `modules/compliance` + `live/45-compliance` | ✅ | ✅ | account | CSIP risk scan |
| `modules/logging` + `live/50-logging` | ✅ | ✅ | account | CLS audit logset/topic + CloudAudit track |
| `modules/delegation` + `live/55-delegation` | ✅ | ✅ | account | org share unit + member delegation |
| `modules/finops` + `live/60-finops` | ✅ | ✅ | account | cost-allocation tags + budgets |
| `modules/workload-onboarding` + `live/70-workload-onboarding` | ✅ | ✅ | account | workload CAM role + tags |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
