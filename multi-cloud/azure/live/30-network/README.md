# live/30-network (Azure)

Hub-Spoke network baseline in the connectivity subscription: hub, dev and prod
VNets with non-overlapping address spaces (10.0/16, 10.10/16, 10.30/16) and a
default-deny NSG on every subnet. Peering and the sandbox→prod deny are layered
in `live/35-connectivity`.

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
terraform validate
terraform plan -var subscription_id=<connectivity-sub-guid>
# apply after PR review + approval
```
