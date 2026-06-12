# AWS policies (Conftest / Rego)

Policy-as-code guardrails evaluated against Terraform plan JSON
(`terraform show -json`). They complement AWS Organizations SCP and Tag Policy
resources by catching unsafe plan-time changes before apply.

## Policies

| File | Rule |
|---|---|
| [organizations.rego](organizations.rego) | Organizations SCP documents must not contain broad Allow statements or wildcard bypass conditions. |
| [iam_trust.rego](iam_trust.rego) | IAM role trust policies must not trust wildcard AWS or federated principals. |
| [iam_policy.rego](iam_policy.rego) | IAM managed policies must not allow `*` on `*` unless they are explicit permission boundary policies. |
| [s3_state.rego](s3_state.rego) | S3 state buckets must use public access blocks, versioning and default encryption resources. |
| [tags.rego](tags.rego) | Taggable resources must include `managed_by`; partial enterprise tag sets must be completed. |

Each policy ships with a `*_test.rego` file for offline unit tests.

## Run

```bash
conftest verify --policy multi-cloud/aws/policies

# If conftest is unavailable, run the Rego unit tests directly:
opa test multi-cloud/aws/policies
```

## Plan enforcement

```bash
terraform -chdir=multi-cloud/aws/live/40-security plan -out plan.tfplan
terraform -chdir=multi-cloud/aws/live/40-security show -json plan.tfplan > plan.json
conftest test --policy multi-cloud/aws/policies plan.json
```
