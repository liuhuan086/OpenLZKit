# live/30-network (Tencent Cloud)

Hub-Spoke network baseline: hub, dev and prod VPCs with non-overlapping CIDRs
(10.0/16, 10.10/16, 10.30/16) and a default-deny baseline security group.
Inter-VPC connectivity (CCN) and sandbox isolation are layered in
`live/35-connectivity`.

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan
# apply after PR review + approval
```
