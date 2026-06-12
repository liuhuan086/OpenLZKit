# AWS workload onboarding model

This model covers the final handoff from the landing zone platform team to a
business workload team.

## Inputs from earlier domains

- Account id and OU placement from `account-factory` and `department`.
- VPC, subnet and endpoint details from `network`.
- Transit Gateway or shared network details from `connectivity`.
- Permission set names and operating groups from `identity-center`.
- Logging, compliance and FinOps guardrails from their dedicated modules.

## Onboarding contract

Each workload should publish:

- department, owner, cost center, environment and project metadata.
- data classification and service tier.
- target AWS account and network attachment references.
- permission set names used by operators or break-glass users.
- trusted platform, CI/CD or operations principals for workload access.
- SSM Parameter Store metadata names for audit and automation discovery.

## Guardrails

- Wildcard trusted principals are rejected at Terraform validation time.
- Inline IAM policies must be valid JSON.
- Ownership and cost tags are required for every workload.
- The module creates no account, VPC or SSO resource by itself, keeping the
  onboarding contract separate from foundation provisioning.
