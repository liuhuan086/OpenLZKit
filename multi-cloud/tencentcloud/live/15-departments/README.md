# live/15-departments (Tencent Cloud)

Business-department management (FP-3): one organization node per department under
the Workloads node, each with its own admin CAM role and optional manage-policy
attachment.

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan -var parent_node_id=<workloads-node-id> -var management_uin=<root-uin>
# apply after PR review + approval
```
