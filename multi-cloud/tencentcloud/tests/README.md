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
terraform -chdir=live/20-identity init -backend=false && terraform -chdir=live/20-identity validate
terraform -chdir=live/30-network  init -backend=false && terraform -chdir=live/30-network  validate
terraform -chdir=live/40-security init -backend=false && terraform -chdir=live/40-security validate
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
| `modules/identity` + `live/20-identity` | ✅ | ✅ | account | CAM policies + roles |
| `modules/network` + `live/30-network` | ✅ | ✅ | account | Hub-Spoke VPCs; default-deny SG |
| `modules/control-policies` + `live/40-security` | ✅ | ✅ | account | org manage-policy guardrails |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
