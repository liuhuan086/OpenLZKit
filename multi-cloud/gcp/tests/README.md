# GCP tests

Static checks run locally without a project; `plan`/integration checks require a
sandbox project/organization with the appropriate IAM.

## Static (no project) — CI gate

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

## Plan / integration (sandbox project) — manual

```bash
# short-lived credentials via Workload Identity Federation / gcloud auth
terraform -chdir=live/10-org plan -var project_id=<seed-project> -var org_id=<org-number>
```

## Coverage

| Target | fmt | validate | plan | notes |
|---|:--:|:--:|:--:|---|
| `live/00-bootstrap` | ✅ | ✅ | proj | local state → migrate to GCS; WIF CI identity |
| `modules/org` + `live/10-org` | ✅ | ✅ | proj | folder hierarchy |
| `modules/project-factory` | ✅ | ✅ | proj | project vending (off by default) |
| `modules/department` + `live/15-departments` | ✅ | ✅ | proj | department folder + IAM + budget |
| `modules/identity` + `live/20-identity` | ✅ | ✅ | proj | custom IAM roles + bindings |
| `modules/cross-account-access` + `live/24-cross-account-access` | ✅ | ✅ | proj | service accounts + WIF + cross-project IAM |
| `modules/identity-groups` + `live/25-sso` | ✅ | ✅ | proj | Cloud Identity groups + IAM |
| `modules/network` + `live/30-network` | ✅ | ✅ | proj | custom VPC; flow logs; default-deny firewall |
| `modules/connectivity` + `live/35-connectivity` | ✅ | ✅ | proj | Shared VPC host + service attach |
| `modules/org-policies` + `live/40-security` | ✅ | ✅ | proj | Organization Policy guardrails |
| `modules/compliance` + `live/45-compliance` | ✅ | ✅ | proj | SCC findings export + notifications |
| `modules/logging` + `live/50-logging` | ✅ | ✅ | proj | central log archive + aggregated sink |
| `modules/delegation` + `live/55-delegation` | ✅ | ✅ | proj | folder IAM delegation + subnet sharing |
| `modules/finops` + `live/60-finops` | ✅ | ✅ | proj | Cloud Billing budgets |
| `modules/workload-onboarding` + `live/70-workload-onboarding` | ✅ | ✅ | proj | workload SA + team IAM + labels |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
