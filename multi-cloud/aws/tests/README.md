# AWS tests

Static checks run locally without a cloud account; `plan`/integration checks
require a sandbox AWS Organization or delegated sandbox account.

## Static (no account) — CI gate

```bash
# Documentation links / text checks
rg -n "FP-1|FP-10|Organizations|IAM Identity Center|Transit Gateway" docs README.md

# Terraform checks will be added per feature point:
# terraform -chdir=examples/<feature> fmt -check -recursive
# terraform -chdir=examples/<feature> init -backend=false
# terraform -chdir=examples/<feature> validate
```

## Plan / integration (sandbox account) — manual

Use short-lived credentials from a sandbox management/delegated account. Do not
run organization-level `apply` from a personal admin session.

## Coverage

| Target | fmt | validate | plan | notes |
|---|:--:|:--:|:--:|---|
| `docs/enterprise-scenarios.md` | — | text | — | FP-1..FP-10 AWS enterprise roadmap |
| `modules/*` | pending | pending | account | implemented feature by feature |
| `live/*` | pending | pending | account | implemented feature by feature |
| `policies/` | pending | pending | — | AWS Conftest/Rego guardrails pending |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
