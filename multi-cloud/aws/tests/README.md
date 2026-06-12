# AWS tests

Static checks run locally without a cloud account; `plan`/integration checks
require a sandbox AWS Organization or delegated sandbox account.

## Static (no account) — CI gate

```bash
# Documentation links / text checks
rg -n "FP-1|FP-10|Organizations|IAM Identity Center|Transit Gateway" docs README.md

# FP-1 Organizations OU baseline
terraform -chdir=multi-cloud/aws/examples/basic fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/basic init -backend=false
terraform -chdir=multi-cloud/aws/examples/basic validate

# FP-1 account vending contract
terraform -chdir=multi-cloud/aws/examples/account-factory fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/account-factory init -backend=false
terraform -chdir=multi-cloud/aws/examples/account-factory validate

# FP-1 live deployment entry
terraform -chdir=multi-cloud/aws/live/10-org fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/10-org init -backend=false
terraform -chdir=multi-cloud/aws/live/10-org validate

# FP-2 Organizations policy guardrails
terraform -chdir=multi-cloud/aws/examples/org-policies fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/org-policies init -backend=false
terraform -chdir=multi-cloud/aws/examples/org-policies validate

terraform -chdir=multi-cloud/aws/live/40-security fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/40-security init -backend=false
terraform -chdir=multi-cloud/aws/live/40-security validate

conftest verify --policy multi-cloud/aws/policies

# FP-3 business departments
terraform -chdir=multi-cloud/aws/examples/departments fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/departments init -backend=false
terraform -chdir=multi-cloud/aws/examples/departments validate

terraform -chdir=multi-cloud/aws/live/15-departments fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/15-departments init -backend=false
terraform -chdir=multi-cloud/aws/live/15-departments validate

# FP-4 cross-account access
terraform -chdir=multi-cloud/aws/examples/cross-account-access fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/cross-account-access init -backend=false
terraform -chdir=multi-cloud/aws/examples/cross-account-access validate

terraform -chdir=multi-cloud/aws/live/24-cross-account-access fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/24-cross-account-access init -backend=false
terraform -chdir=multi-cloud/aws/live/24-cross-account-access validate

# FP-5 IAM Identity Center
terraform -chdir=multi-cloud/aws/examples/identity fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/identity init -backend=false
terraform -chdir=multi-cloud/aws/examples/identity validate

terraform -chdir=multi-cloud/aws/live/20-identity fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/20-identity init -backend=false
terraform -chdir=multi-cloud/aws/live/20-identity validate

terraform -chdir=multi-cloud/aws/examples/identity-center fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/identity-center init -backend=false
terraform -chdir=multi-cloud/aws/examples/identity-center validate

terraform -chdir=multi-cloud/aws/live/25-sso fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/25-sso init -backend=false
terraform -chdir=multi-cloud/aws/live/25-sso validate

# FP-6 Transit Gateway connectivity
terraform -chdir=multi-cloud/aws/examples/network fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/network init -backend=false
terraform -chdir=multi-cloud/aws/examples/network validate

terraform -chdir=multi-cloud/aws/live/30-network fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/30-network init -backend=false
terraform -chdir=multi-cloud/aws/live/30-network validate

terraform -chdir=multi-cloud/aws/examples/connectivity fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/connectivity init -backend=false
terraform -chdir=multi-cloud/aws/examples/connectivity validate

terraform -chdir=multi-cloud/aws/live/35-connectivity fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/35-connectivity init -backend=false
terraform -chdir=multi-cloud/aws/live/35-connectivity validate

# FP-7 runtime compliance
terraform -chdir=multi-cloud/aws/examples/compliance fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/compliance init -backend=false
terraform -chdir=multi-cloud/aws/examples/compliance validate

terraform -chdir=multi-cloud/aws/live/45-compliance fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/45-compliance init -backend=false
terraform -chdir=multi-cloud/aws/live/45-compliance validate

# FP-8 delegated administration and governed RAM sharing
terraform -chdir=multi-cloud/aws/examples/delegation fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/delegation init -backend=false
terraform -chdir=multi-cloud/aws/examples/delegation validate

terraform -chdir=multi-cloud/aws/live/55-delegation fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/55-delegation init -backend=false
terraform -chdir=multi-cloud/aws/live/55-delegation validate

# FP-9 logging and audit archive
terraform -chdir=multi-cloud/aws/examples/logging fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/logging init -backend=false
terraform -chdir=multi-cloud/aws/examples/logging validate

terraform -chdir=multi-cloud/aws/live/50-logging fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/50-logging init -backend=false
terraform -chdir=multi-cloud/aws/live/50-logging validate

# FP-10 FinOps
terraform -chdir=multi-cloud/aws/examples/finops fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/finops init -backend=false
terraform -chdir=multi-cloud/aws/examples/finops validate

terraform -chdir=multi-cloud/aws/live/60-finops fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/60-finops init -backend=false
terraform -chdir=multi-cloud/aws/live/60-finops validate

# Workload onboarding handoff
terraform -chdir=multi-cloud/aws/examples/workload-onboarding fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/workload-onboarding init -backend=false
terraform -chdir=multi-cloud/aws/examples/workload-onboarding validate

terraform -chdir=multi-cloud/aws/live/70-workload-onboarding fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/70-workload-onboarding init -backend=false
terraform -chdir=multi-cloud/aws/live/70-workload-onboarding validate
```

## Plan / integration (sandbox account) — manual

Use short-lived credentials from a sandbox management/delegated account. Do not
run organization-level `apply` from a personal admin session.

## Coverage

| Target | fmt | validate | plan | notes |
|---|:--:|:--:|:--:|---|
| `docs/enterprise-scenarios.md` | — | text | — | FP-1..FP-10 AWS enterprise roadmap |
| `modules/org` | yes | via examples/basic | account | FP-1 OU hierarchy |
| `modules/account-factory` | yes | via examples/account-factory | account | FP-1 account vending, apply requires approval |
| `live/10-org` | yes | yes | account | FP-1 deployment entry; accounts default empty |
| `modules/org-policies` | yes | via examples/org-policies | account | FP-2 SCP and Tag Policy |
| `live/40-security` | yes | yes | account | FP-2 deployment entry; attachments default empty |
| `policies/organizations.rego` | — | conftest verify | — | FP-2 Organizations policy guardrail tests |
| `modules/department` | yes | via examples/departments | account | FP-3 department OU, admin role and tag baseline |
| `live/15-departments` | yes | yes | account | FP-3 deployment entry; departments default empty |
| `modules/cross-account-access` | yes | via examples/cross-account-access | account | FP-4 STS, OIDC and AWS RAM sharing |
| `live/24-cross-account-access` | yes | yes | account | FP-4 deployment entry; access maps default empty |
| `policies/iam_trust.rego` | — | conftest verify | — | FP-4 trust policy wildcard principal guardrail tests |
| `modules/identity` | yes | via examples/identity | account | IAM account alias, password policy, permission boundaries and customer policies |
| `live/20-identity` | yes | yes | account | account-local IAM baseline deployment entry |
| `modules/identity-center` | yes | via examples/identity-center | account | FP-5 permission sets, assignments and optional Identity Store objects |
| `live/25-sso` | yes | yes | account | FP-5 deployment entry; maps default empty |
| `modules/network` | yes | via examples/network | account | VPC, subnet, route table, endpoints, flow logs baseline |
| `live/30-network` | yes | yes | account | VPC baseline deployment entry |
| `modules/connectivity` | yes | via examples/connectivity | account | FP-6 Transit Gateway, route table isolation and AWS RAM sharing |
| `live/35-connectivity` | yes | yes | account | FP-6 deployment entry; maps default empty |
| `modules/compliance` | yes | via examples/compliance | account | FP-7 AWS Config, Security Hub and GuardDuty |
| `live/45-compliance` | yes | yes | account | FP-7 deployment entry; maps default empty |
| `modules/delegation` | yes | via examples/delegation | account | FP-8 Organizations delegated admin and governed RAM sharing |
| `live/55-delegation` | yes | yes | account | FP-8 deployment entry; maps default empty |
| `modules/logging` | yes | via examples/logging | account | FP-9 CloudTrail, S3 log archive, KMS and Object Lock |
| `live/50-logging` | yes | yes | account | FP-9 deployment entry |
| `modules/finops` | yes | via examples/finops | account | FP-10 budgets, cost anomaly detection and cost categories |
| `live/60-finops` | yes | yes | account | FP-10 deployment entry; maps default empty |
| `modules/workload-onboarding` | yes | via examples/workload-onboarding | account | workload access role and metadata handoff |
| `live/70-workload-onboarding` | yes | yes | account | workload onboarding deployment entry; maps default empty |
| `modules/*` | pending | pending | account | remaining feature points |
| `live/*` | pending | pending | account | remaining feature points |
| `policies/` | partial | conftest verify | — | FP-2 Organizations guardrail present; more guardrails pending |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
