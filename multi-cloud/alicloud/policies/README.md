# Alibaba Cloud policies (Conftest / Rego)

Policy-as-code guardrails evaluated against **Terraform plan JSON**
(`terraform show -json`). They encode, as enforceable rules, the defaults the
modules already assume.

## Policies

| File | Rule |
|---|---|
| [tags.rego](tags.rego) | Taggable resources must carry the FinOps tag set (`owner`, `cost_center`, `env`, `project`). |
| [network.rego](network.rego) | Deny public ingress (`0.0.0.0/0`) to high-risk ports (22, 3389). |
| [encryption.rego](encryption.rego) | OSS buckets must have server-side encryption; bucket ACLs must not be public. |

Each policy ships with a `*_test.rego` of positive **and** negative cases.

## Run the unit tests (offline, no cloud account)

```bash
conftest verify --policy multi-cloud/alicloud/policies
```

This runs in CI (`terraform-checks` → `policy` job) on every PR.

## Enforce against a real plan (in a pipeline / sandbox)

```bash
terraform -chdir=live/30-network plan -out plan.tfplan
terraform -chdir=live/30-network show -json plan.tfplan > plan.json
conftest test --policy multi-cloud/alicloud/policies plan.json
```

## Notes

- These complement (don't replace) the module defaults — they catch drift and
  hand-written changes before apply.
- Add new rules with matching `*_test.rego` cases so CI proves them.
