# live/40-security (Tencent Cloud)

Organization guardrails as manage policies (FP-2), attached at the root node:

- Deny disabling/deleting CloudAudit tracks.
- Deny member accounts quitting the organization.

Child nodes and members inherit these denies.

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate
terraform plan -var root_node_id=<root-node-id>
# apply after PR review + approval; manage policies change the permission surface of all child members
```
