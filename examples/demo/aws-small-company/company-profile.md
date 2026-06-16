# Company Profile

## Business Context

Acme Payments Example is an 80-person SaaS company moving its payment API from manually managed AWS accounts to a governed landing zone. The company has one platform team, one security team and one product engineering team that owns the payments workload.

All values in this demo are fake. Emails use `example.com`, account names are illustrative and no real AWS organization, account, ARN or bucket name is included.

## Teams

| Team | Responsibility | Required access |
|---|---|---|
| Platform | Landing zone, account vending, network and CI/CD roles | Admin in management, network and shared services scopes |
| Security | Audit, guardrails, incident review and findings triage | Read-only across accounts; admin in security tooling |
| Payments | Build and operate `payments-api` | Developer access in dev; operator access in prod |
| Finance | Cost ownership and budget review | Budget and CUR summaries by cost center |

## Business Requirements

- Create isolated AWS accounts for security tooling, log archive, network, payments dev and payments prod.
- Keep dev and prod in separate workload OUs and separate accounts.
- Route workload traffic through a network account and deny sandbox-to-prod propagation.
- Require short-lived access through IAM Identity Center or GitHub OIDC AssumeRole.
- Enforce `managed_by`, `owner`, `cost_center` and `environment` metadata.
- Keep audit logs and Terraform state private, encrypted and versioned.

## Demo Success Criteria

| Area | Success signal |
|---|---|
| Account vending | Requested accounts map to the expected OU tree and have owner, environment and budget metadata |
| Workload onboarding | `payments-api` has a target account, network tier, access groups, OIDC subject and handoff evidence |
| Security controls | Public object storage, unencrypted state and wildcard trust are blocked by policy review |
| Network | Prod, dev and sandbox route tables remain isolated as documented |
| Evidence | The walkthrough names the expected plan, policy, audit, rollback and handoff artifacts |
