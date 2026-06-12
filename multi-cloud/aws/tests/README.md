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
| `modules/*` | pending | pending | account | remaining feature points |
| `live/*` | pending | pending | account | remaining feature points |
| `policies/` | partial | conftest verify | — | FP-2 Organizations guardrail present; more guardrails pending |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
