# Sanitized Plan Output

This directory is reserved for small, reviewed Terraform plan summaries that are safe to publish. `v0.1.0` does not include real plan output because no AWS sandbox apply is claimed.

## Accepted Content

- Human-written summaries of `terraform show -json` output.
- Resource action counts by Terraform resource type.
- Policy check results from already sanitized inputs.
- Notes explaining why a stack was `dry-run-only` or `manual-check-only`.

## Prohibited Content

- Raw `terraform plan`, `terraform.tfstate` or `terraform.tfstate.backup`.
- Real account IDs, ARNs, bucket names, emails, source IPs or identity provider IDs.
- Secret values, access keys, private keys or provider credentials.
- Full CloudTrail events or Security Hub findings with resource identifiers.

## Example Summary

```text
Stack: multi-cloud/aws/live/00-bootstrap
Apply type: dry-run-only
Region: us-east-1
Plan summary:
- aws_s3_bucket: create 1 state bucket
- aws_dynamodb_table: create 1 lock table
- aws_kms_key: create 1 optional state key
Policy checks:
- Checkov: pass for encryption, versioning and public access block controls
- Conftest: no state bucket public access exceptions
Identifiers: redacted
```
