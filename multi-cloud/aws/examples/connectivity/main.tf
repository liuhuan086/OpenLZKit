module "connectivity" {
  source = "../../modules/connectivity"

  name_prefix = "lz-"

  transit_gateway = {
    name        = "core"
    description = "Landing Zone core Transit Gateway"
  }

  route_tables = {
    shared  = { name = "shared" }
    prod    = { name = "prod" }
    nonprod = { name = "nonprod" }
    sandbox = { name = "sandbox" }
  }

  vpc_attachments = {
    shared_services = {
      name              = "shared-services"
      vpc_id            = "vpc-00000000000000001"
      subnet_ids        = ["subnet-00000000000000001", "subnet-00000000000000002"]
      route_table_key   = "shared"
      propagate_to_keys = ["prod", "nonprod"]
    }
    prod_payments = {
      name              = "prod-payments"
      vpc_id            = "vpc-00000000000000002"
      subnet_ids        = ["subnet-00000000000000003", "subnet-00000000000000004"]
      route_table_key   = "prod"
      propagate_to_keys = ["shared"]
    }
    sandbox_lab = {
      name              = "sandbox-lab"
      vpc_id            = "vpc-00000000000000003"
      subnet_ids        = ["subnet-00000000000000005", "subnet-00000000000000006"]
      route_table_key   = "sandbox"
      propagate_to_keys = []
    }
  }

  routes = {
    sandbox_to_prod_blackhole = {
      route_table_key        = "sandbox"
      destination_cidr_block = "10.10.0.0/16"
      blackhole              = true
    }
  }

  ram_shares = {
    shared_tgw = {
      name                  = "shared-tgw"
      principals            = ["222233334444"]
      share_transit_gateway = true
    }
  }
}
