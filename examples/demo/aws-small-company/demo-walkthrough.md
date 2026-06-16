# AWS Small Company Demo Walkthrough

This walkthrough is intentionally cloud-free. It shows how a reviewer can read the demo request files and understand the expected AWS Landing Zone path before any sandbox account exists.

## Step 1: Review the Company Profile

Read [company-profile.md](company-profile.md) to understand the business context, teams and success criteria. The key decision is that AWS accounts are the isolation boundary, while shared standards come from tags, CI gates, policy-as-code and evidence requirements.

## Step 2: Review the Organization Request

Open [org-request.yaml](org-request.yaml). The requested OU model is:

- `security` for log archive and security tooling.
- `infrastructure` for network and shared services.
- `workloads/dev` and `workloads/prod` for environment isolation.
- `sandbox` for experiments outside the production promotion path.

Compare it with [expected-ou-tree.md](expected-ou-tree.md). Any change to OU names or nesting should be reviewed for state compatibility and SCP inheritance impact.

## Step 3: Review Account Vending

Open [account-request.yaml](account-request.yaml). Each account request must include:

- A fake `example.com` email in the demo.
- A target OU path.
- An owner, environment, cost center and budget limit.
- Required access groups for IAM Identity Center assignments.

For a real sandbox apply, these requests would be translated into `multi-cloud/aws/live/10-org` inputs or an Account Factory for Terraform integration. In this demo, the file is a review artifact only.

## Step 4: Review Workload Onboarding

Open [workload-request.yaml](workload-request.yaml). The `payments-api` workload requests prod access in `app-prod-payments`, a `spoke-prod` network tier and GitHub OIDC access from a single repo subject.

The expected handoff is a small contract for the workload team:

| Handoff item | Expected source |
|---|---|
| Account and OU | `account-request.yaml`, `expected-ou-tree.md` |
| Network tier and allowed paths | `workload-request.yaml`, `expected-network.md` |
| Human and CI access | `workload-request.yaml`, IAM Identity Center and OIDC role plan |
| Required evidence | `workload-request.yaml`, `expected-controls.md` |

## Step 5: Map Controls to Evidence

Read [expected-controls.md](expected-controls.md), then map each row to the repository-level control matrix in [../../../docs/compliance/control-mapping.md](../../../docs/compliance/control-mapping.md).

The important review question is not "did Terraform run", but "can the team show how each security, identity, network, logging and FinOps control will be checked and evidenced".

## Step 6: Review the Static Gate

Run the dependency-free release gate:

```bash
python3 tools/static_release_gate.py
```

This checks that required demo and release artifacts exist, markdown links resolve, request examples have required metadata and obvious sensitive values are not committed.

## Step 7: Promote to Sandbox Evidence

When a real AWS sandbox is available, follow [../../../docs/runbooks/aws-apply-order.md](../../../docs/runbooks/aws-apply-order.md) and write the sanitized result to [../../../docs/demo/aws-sandbox-apply-report.md](../../../docs/demo/aws-sandbox-apply-report.md).

Store only sanitized summaries in this repository. Raw plan files, CloudTrail events, account IDs, ARNs, bucket names, source IPs and emails must remain in a private evidence store.
