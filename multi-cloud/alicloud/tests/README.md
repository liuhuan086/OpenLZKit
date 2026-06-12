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

# validate the live stacks (backend disabled)
terraform -chdir=live/00-bootstrap init -backend=false
terraform -chdir=live/00-bootstrap validate
terraform -chdir=live/10-org init -backend=false
terraform -chdir=live/10-org validate
terraform -chdir=live/20-identity init -backend=false
terraform -chdir=live/20-identity validate
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
| `modules/org` (via `examples/basic`) | ✅ | ✅ | account | folders only; accounts off by default |
| `live/10-org` | ✅ | ✅ | account | OSS backend via `-backend-config` |
| `modules/identity` + `live/20-identity` | ✅ | ✅ | account | assumable RAM roles; no long-lived users |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
