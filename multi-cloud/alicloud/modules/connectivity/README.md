# Module: alicloud/connectivity

Creates Alibaba Cloud CEN / Transit Router connectivity for a hub-spoke Landing
Zone network.

## Responsibilities

- Create or reuse a CEN instance.
- Create a Transit Router.
- Create Transit Router route tables.
- Attach VPCs to Transit Router, including cross-account VPC owner ids.
- Grant cross-account attachment rights when the CEN owner and network instance
  owner differ.
- Associate/propagate attachments with route tables.
- Create explicit route entries for controlled reachability.

It does **not**:

- Create VPCs or vSwitches — use `modules/network`.
- Manage security group rules or workload firewall policy.
- Replace route review for production/sandbox isolation.

## Usage

```hcl
module "connectivity" {
  source = "../../modules/connectivity"

  name_prefix = "lz-"

  route_tables = {
    shared = { name = "shared" }
    prod   = { name = "prod" }
  }

  vpc_attachments = {
    shared_services = {
      name         = "shared-services"
      vpc_id       = "vpc-shared"
      zone_mappings = [{
        zone_id    = "cn-hangzhou-h"
        vswitch_id = "vsw-shared-a"
      }]
      route_table_association_key = "shared"
      route_table_propagation_key = "shared"
    }
  }
}
```

## Security notes

- Keep sandbox in a separate route table and do not propagate sandbox routes to
  production route tables.
- Prefer explicit route entries for sensitive segments.
- Cross-account grants should be scoped to the exact VPC/VBR/VPN instance.

## Testing

```bash
terraform -chdir=examples/connectivity fmt -check -recursive
terraform -chdir=examples/connectivity init -backend=false
terraform -chdir=examples/connectivity validate
```
