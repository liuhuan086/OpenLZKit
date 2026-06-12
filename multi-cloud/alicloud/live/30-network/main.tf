variable "region" {
  description = "Alibaba Cloud region for the provider."
  type        = string
  default     = "cn-hangzhou"
}

variable "zone_a" {
  description = "Primary availability zone id."
  type        = string
  default     = "cn-hangzhou-i"
}

variable "zone_b" {
  description = "Secondary availability zone id."
  type        = string
  default     = "cn-hangzhou-j"
}

provider "alicloud" {
  region = var.region
}

# Hub-Spoke baseline. Non-overlapping CIDRs per docs/design/02 (shared 10.0/16,
# dev 10.10/16, prod 10.30/16). Inter-VPC connectivity (CEN/Transit Router) and
# the sandbox->prod deny are added on top of these spokes.
module "hub" {
  source     = "../../modules/network"
  name       = "hub"
  cidr_block = "10.0.0.0/16"
  vswitches = {
    a = { zone_id = var.zone_a, cidr_block = "10.0.1.0/24" }
    b = { zone_id = var.zone_b, cidr_block = "10.0.2.0/24" }
  }
}

module "dev" {
  source     = "../../modules/network"
  name       = "dev"
  cidr_block = "10.10.0.0/16"
  vswitches = {
    a = { zone_id = var.zone_a, cidr_block = "10.10.1.0/24" }
    b = { zone_id = var.zone_b, cidr_block = "10.10.2.0/24" }
  }
}

module "prod" {
  source     = "../../modules/network"
  name       = "prod"
  cidr_block = "10.30.0.0/16"
  vswitches = {
    a = { zone_id = var.zone_a, cidr_block = "10.30.1.0/24" }
    b = { zone_id = var.zone_b, cidr_block = "10.30.2.0/24" }
  }
}

output "vpc_ids" {
  description = "VPC ids by tier."
  value = {
    hub  = module.hub.vpc_id
    dev  = module.dev.vpc_id
    prod = module.prod.vpc_id
  }
}
