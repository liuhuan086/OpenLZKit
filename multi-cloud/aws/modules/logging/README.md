# Module: aws/logging

Builds the central AWS log archive foundation.

## Responsibilities

- Create or consume a central S3 log archive bucket.
- Enable bucket versioning, public access block, SSE and optional Object Lock.
- Create or consume a KMS key for log encryption.
- Create a CloudWatch log group for CloudTrail delivery.
- Create an organization CloudTrail with log file validation.
- Create optional Kinesis Data Firehose delivery streams into the log archive.
- Create optional Security Lake data lakes and AWS log sources.

It does **not**:

- Create custom Security Lake sources, subscribers or SIEM integrations.
- Create every workload service log source.
- Replace FP-7 runtime compliance findings aggregation.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/logging fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/logging init -backend=false
terraform -chdir=multi-cloud/aws/examples/logging validate
```
