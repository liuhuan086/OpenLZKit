# live/35-connectivity (Azure)

Hub-Spoke peering (FP-6): each spoke VNet peers bidirectionally with the hub
only. Spoke↔spoke (dev↔prod, sandbox↔prod) is intentionally omitted so those
paths stay denied. VNet ids come from `live/30-network`.

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
terraform plan \
  -var subscription_id=<connectivity-sub-guid> \
  -var hub_vnet_id=<hub-vnet-id> \
  -var 'spoke_vnets={prod={vnet_name="lz-prod",vnet_id="<prod-vnet-id>"}}'
# apply after PR review + approval
```
