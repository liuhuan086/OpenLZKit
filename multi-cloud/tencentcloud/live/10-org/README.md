# live/10-org (Tencent Cloud)

Organization layer: the TCO node hierarchy via [`org`](../../modules/org) and
member-account vending via [`account-factory`](../../modules/account-factory).
First deployable stack after `00-bootstrap`.

## Hierarchy

```text
Organization Root
├── Security
│   ├── Audit Log
│   └── Security Tooling
├── Infrastructure
│   ├── Network
│   └── Shared Services
├── Workloads
│   ├── Prod
│   └── Dev
└── Sandbox
```

## State

```bash
terraform init -backend-config="bucket=lz-tfstate-1250000000" -backend-config="region=ap-guangzhou"
```

## Workflow

```bash
terraform validate            # static, no account
terraform plan -var root_node_id=<root-node-id>
# apply after PR review + approval; member creation is empty by default
```
