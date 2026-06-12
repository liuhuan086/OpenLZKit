# live/10-org (Azure)

Organization layer: builds the management group hierarchy via [`org`](../../modules/org)
and wires subscription vending via [`subscription-vending`](../../modules/subscription-vending).
First deployable stack after `00-bootstrap`.

## Hierarchy

```text
Tenant Root
├── Platform
│   ├── Identity
│   ├── Management
│   └── Connectivity
├── Landing Zones
│   ├── Corp
│   └── Online
├── Sandbox
└── Decommissioned
```

## State

```bash
terraform init \
  -backend-config="resource_group_name=lz-tfstate-rg" \
  -backend-config="storage_account_name=mylztfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="use_azuread_auth=true"
```

## Workflow

```bash
terraform validate            # static, no subscription
terraform plan                # requires Management Group Contributor + tenant-root access
# apply runs only after PR review + environment approval
```

Subscription placement is empty by default — populate `subscription_associations`
with reviewed subscription ids.
