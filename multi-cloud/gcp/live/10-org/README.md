# live/10-org (GCP)

Organization layer: the folder hierarchy via [`org`](../../modules/org) and
project vending via [`project-factory`](../../modules/project-factory). First
deployable stack after `00-bootstrap`.

## Hierarchy

```text
Organization
├── Common
│   ├── Logging
│   ├── Monitoring
│   └── Security
├── Networking
├── Workloads
│   ├── Prod
│   └── Dev
└── Sandbox
```

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate            # static, no project
terraform plan -var project_id=<seed-project> -var org_id=<org-number>
# apply after PR review + approval; project creation is empty by default
```
