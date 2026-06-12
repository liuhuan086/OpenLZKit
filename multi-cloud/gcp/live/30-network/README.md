# live/30-network (GCP)

Hub-Spoke network baseline in the Shared VPC host project: hub, dev and prod
VPCs with non-overlapping CIDRs (10.0/20, 10.10/20, 10.30/20), VPC flow logs,
and default-deny ingress. Shared VPC service-project attachment and NCC are
layered in `live/35-connectivity`.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan -var host_project_id=<host-project>
# apply after PR review + approval
```
