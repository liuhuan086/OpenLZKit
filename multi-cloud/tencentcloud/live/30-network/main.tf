variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "zone" {
  description = "Availability zone for the subnets."
  type        = string
  default     = "ap-guangzhou-6"
}

provider "tencentcloud" {
  region = var.region
}

# Hub-Spoke baseline with non-overlapping CIDRs. Inter-VPC connectivity (CCN) and
# the sandbox isolation are layered in live/35-connectivity.
module "hub" {
  source     = "../../modules/network"
  name       = "hub"
  cidr_block = "10.0.0.0/16"
  subnets = {
    shared = { availability_zone = var.zone, cidr_block = "10.0.1.0/24" }
  }
}

module "dev" {
  source     = "../../modules/network"
  name       = "dev"
  cidr_block = "10.10.0.0/16"
  subnets = {
    workload = { availability_zone = var.zone, cidr_block = "10.10.1.0/24" }
  }
}

module "prod" {
  source     = "../../modules/network"
  name       = "prod"
  cidr_block = "10.30.0.0/16"
  subnets = {
    workload = { availability_zone = var.zone, cidr_block = "10.30.1.0/24" }
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
