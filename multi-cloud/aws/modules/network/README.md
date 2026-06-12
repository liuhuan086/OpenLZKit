# Module: aws/network

Builds the account-level VPC baseline for AWS Landing Zone workloads and
shared-service accounts.

## Responsibilities

- Create a VPC with DNS settings and tags.
- Create public/private/isolated subnets and route tables.
- Optionally create an Internet Gateway and NAT gateways.
- Create VPC endpoints.
- Create baseline security groups.
- Create VPC Flow Logs to an existing destination.

It does **not**:

- Create Transit Gateway resources; use `modules/connectivity`.
- Create centralized log buckets; use `modules/logging`.
- Create Network Firewall or inspection appliances.

## Testing

```bash
terraform -chdir=multi-cloud/aws/examples/network fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/network init -backend=false
terraform -chdir=multi-cloud/aws/examples/network validate
```
