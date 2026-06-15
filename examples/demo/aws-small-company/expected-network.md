# Expected Network

## Topology

```text
network account
  └── Transit Gateway
      ├── shared-services route table
      ├── prod route table
      ├── dev route table
      └── sandbox route table

app-prod-payments -> prod route table -> shared-services only
app-dev-payments  -> dev route table  -> shared-services only
sandbox           -> sandbox route table, no prod propagation
```

## Controls

- Prod and dev do not share VPCs.
- Sandbox does not propagate routes to prod.
- VPC Flow Logs are enabled and sent to the logging path.
- Egress is explicit; no workload account creates unmanaged internet egress by default.
- DNS and shared services are consumed through the shared-services route table.
