variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

module "connectivity" {
  source = "../../modules/connectivity"

  name_prefix = "lz-"
  cen_name    = "enterprise-hub"

  route_tables = {
    shared = {
      name        = "shared"
      description = "Shared-services route table."
    }
    prod = {
      name        = "prod"
      description = "Production route table."
    }
    sandbox = {
      name        = "sandbox"
      description = "Sandbox route table, intentionally isolated from prod."
    }
  }

  vpc_attachments = {
    shared_services = {
      name                       = "shared-services"
      vpc_id                     = "vpc-shared-example"
      auto_publish_route_enabled = false
      zone_mappings = [{
        zone_id    = "cn-hangzhou-h"
        vswitch_id = "vsw-shared-example-a"
      }]
      route_table_association_key = "shared"
      route_table_propagation_key = "shared"
    }
    prod_app = {
      name                       = "prod-app"
      vpc_id                     = "vpc-prod-example"
      vpc_owner_id               = "1234567890123456"
      auto_publish_route_enabled = false
      zone_mappings = [{
        zone_id    = "cn-hangzhou-h"
        vswitch_id = "vsw-prod-example-a"
      }]
      route_table_association_key = "prod"
      route_table_propagation_key = "prod"
    }
  }

  grant_attachments = {
    prod_app = {
      cen_owner_id  = "1111222233334444"
      instance_id   = "vpc-prod-example"
      instance_type = "VPC"
    }
  }

  route_entries = {
    prod_to_shared = {
      route_table_key  = "prod"
      destination_cidr = "10.10.0.0/16"
      next_hop_type    = "Attachment"
      attachment_key   = "shared_services"
      name             = "prod-to-shared"
    }
  }
}

output "cen_id" {
  description = "CEN instance id."
  value       = module.connectivity.cen_id
}

output "transit_router_id" {
  description = "Transit Router id."
  value       = module.connectivity.transit_router_id
}
