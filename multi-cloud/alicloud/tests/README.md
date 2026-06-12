# Alibaba Cloud tests

Static checks run locally without a cloud account; `plan`/integration checks
require a sandbox management account with Resource Directory permissions.

## Static (no account) — CI gate

```bash
# format
terraform -chdir=examples/basic fmt -check -recursive

# validate the org module via its example
terraform -chdir=examples/basic init -backend=false
terraform -chdir=examples/basic validate

# validate the account factory contract via its example
terraform -chdir=examples/account-factory fmt -check -recursive
terraform -chdir=examples/account-factory init -backend=false
terraform -chdir=examples/account-factory validate

# validate the control policy contract via its example
terraform -chdir=examples/control-policies fmt -check -recursive
terraform -chdir=examples/control-policies init -backend=false
terraform -chdir=examples/control-policies validate

# validate the department contract via its example
terraform -chdir=examples/departments fmt -check -recursive
terraform -chdir=examples/departments init -backend=false
terraform -chdir=examples/departments validate

# validate the cross-account access contract via its example
terraform -chdir=examples/cross-account-access fmt -check -recursive
terraform -chdir=examples/cross-account-access init -backend=false
terraform -chdir=examples/cross-account-access validate

# validate the CloudSSO contract via its example
terraform -chdir=examples/sso fmt -check -recursive
terraform -chdir=examples/sso init -backend=false
terraform -chdir=examples/sso validate

# validate the live stacks (backend disabled)
terraform -chdir=live/00-bootstrap init -backend=false
terraform -chdir=live/00-bootstrap validate
terraform -chdir=live/10-org init -backend=false
terraform -chdir=live/10-org validate
terraform -chdir=live/15-departments init -backend=false
terraform -chdir=live/15-departments validate
terraform -chdir=live/20-identity init -backend=false
terraform -chdir=live/20-identity validate
terraform -chdir=live/24-cross-account-access init -backend=false
terraform -chdir=live/24-cross-account-access validate
terraform -chdir=live/25-sso init -backend=false
terraform -chdir=live/25-sso validate
terraform -chdir=live/30-network init -backend=false
terraform -chdir=live/30-network validate
terraform -chdir=live/40-security init -backend=false
terraform -chdir=live/40-security validate
terraform -chdir=live/50-logging init -backend=false
terraform -chdir=live/50-logging validate
terraform -chdir=live/60-finops init -backend=false
terraform -chdir=live/60-finops validate
terraform -chdir=live/70-workload-onboarding init -backend=false
terraform -chdir=live/70-workload-onboarding validate

# policy-as-code unit tests (Conftest/Rego)
conftest verify --policy policies
```

## Plan / integration (sandbox account) — manual

```bash
# short-lived STS credentials for the management account
terraform -chdir=examples/basic plan -var region=cn-hangzhou
```

## Coverage

| Target | fmt | validate | plan | notes |
|---|:--:|:--:|:--:|---|
| `live/00-bootstrap` | ✅ | ✅ | account | local state → migrate to OSS; OIDC CI role |
| `modules/org` (via `examples/basic`) | ✅ | ✅ | account | folders only |
| `modules/account-factory` (via `examples/account-factory`) | ✅ | ✅ | account | opt-in member accounts + required FinOps tags |
| `live/10-org` | ✅ | ✅ | account | folders + account factory; OSS backend via `-backend-config` |
| `modules/department` (via `examples/departments`) | ✅ | ✅ | account | department folders + roles + tag policies + guardrail attachments |
| `live/15-departments` | ✅ | ✅ | account | opt-in department boundaries; OSS backend via `-backend-config` |
| `modules/identity` + `live/20-identity` | ✅ | ✅ | account | assumable RAM roles; no long-lived users |
| `modules/cross-account-access` (via `examples/cross-account-access`) | ✅ | ✅ | account | target-account RAM roles + Resource Share |
| `live/24-cross-account-access` | ✅ | ✅ | account | opt-in cross-account trust and resource sharing |
| `modules/sso` (via `examples/sso`) | ✅ | ✅ | account | CloudSSO directory + groups + access configurations + assignments |
| `live/25-sso` | ✅ | ✅ | account | opt-in CloudSSO human access |
| `modules/network` + `live/30-network` | ✅ | ✅ | account | Hub-Spoke VPCs; default-deny SG |
| `modules/security` + `modules/control-policies` + `live/40-security` | ✅ | ✅ | account | RAM password policy + opt-in organization guardrails |
| `modules/logging` + `live/50-logging` | ✅ | ✅ | account | SLS audit project + ActionTrail trail |
| `modules/finops` + `live/60-finops` | ✅ | ✅ | account | required-tags tag policy |
| `modules/workload-onboarding` + `live/70-workload-onboarding` | ✅ | ✅ | account | resource group + workload role + tags |
| `policies/` (Conftest) | — | `verify` | — | tags / public-ingress / encryption rules + unit tests |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
