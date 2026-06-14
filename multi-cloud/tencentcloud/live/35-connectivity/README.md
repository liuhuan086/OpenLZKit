# live/35-connectivity (Tencent Cloud)

CCN interconnect (FP-6): a hub Cloud Connect Network with VPC attachments.
Attach only VPCs that should interconnect; the sandbox VPC stays off the CCN.
Attachments are empty by default.

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan -var 'vpc_attachments={prod={instance_id="vpc-xxxx",instance_region="ap-guangzhou"}}'
# apply after PR review + approval
```
