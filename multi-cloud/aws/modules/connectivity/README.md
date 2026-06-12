# Module: aws/connectivity

Builds Transit Gateway based hub-spoke connectivity for AWS Landing Zone
network accounts.

## Responsibilities

- Create or consume a Transit Gateway.
- Create explicit TGW route tables for network zones such as shared, prod,
  nonprod and sandbox.
- Attach VPCs to a TGW with default association and propagation disabled.
- Associate each attachment to exactly one route table.
- Propagate attachments only to reviewed route tables.
- Create explicit TGW routes, including blackhole routes.
- Share the TGW or additional network resources through AWS RAM.

It does **not**:

- Create VPCs, subnets, firewalls or inspection appliances.
- Accept cross-account TGW attachments in spoke accounts.
- Replace network firewall policy or routing approval workflows.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/connectivity fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/connectivity init -backend=false
terraform -chdir=multi-cloud/aws/examples/connectivity validate
```
