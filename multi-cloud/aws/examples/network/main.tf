module "network" {
  source = "../../modules/network"

  name_prefix             = "lz-"
  create_internet_gateway = true

  vpc = {
    name       = "payments-nonprod"
    cidr_block = "10.20.0.0/16"
    tags = {
      owner       = "payments-platform"
      cost_center = "cc-1001"
      env         = "nonprod"
      project     = "payments"
    }
  }

  subnets = {
    public_a = {
      name                    = "public-a"
      cidr_block              = "10.20.0.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      route_table_key         = "public"
    }
    private_a = {
      name              = "private-a"
      cidr_block        = "10.20.10.0/24"
      availability_zone = "us-east-1a"
      route_table_key   = "private"
    }
    isolated_a = {
      name              = "isolated-a"
      cidr_block        = "10.20.20.0/24"
      availability_zone = "us-east-1a"
      route_table_key   = "isolated"
    }
  }

  nat_gateways = {
    public_a = {
      name              = "public-a"
      public_subnet_key = "public_a"
    }
  }

  route_tables = {
    public = {
      name = "public"
      routes = [{
        cidr_block  = "0.0.0.0/0"
        gateway_key = "internet_gateway"
      }]
    }
    private = {
      name = "private"
      routes = [{
        cidr_block      = "0.0.0.0/0"
        nat_gateway_key = "public_a"
      }]
    }
    isolated = {
      name = "isolated"
    }
  }

  security_groups = {
    endpoints = {
      name        = "endpoints"
      description = "VPC interface endpoint ingress."
      ingress = [{
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.20.0.0/16"]
      }]
      egress = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }]
    }
  }

  vpc_endpoints = {
    s3 = {
      service_name      = "com.amazonaws.us-east-1.s3"
      vpc_endpoint_type = "Gateway"
      route_table_keys  = ["private", "isolated"]
    }
    logs = {
      service_name        = "com.amazonaws.us-east-1.logs"
      vpc_endpoint_type   = "Interface"
      subnet_keys         = ["private_a"]
      security_group_keys = ["endpoints"]
    }
  }

  flow_logs = {
    s3 = {
      log_destination      = "arn:aws:s3:::openlzkit-example-flow-logs"
      log_destination_type = "s3"
      traffic_type         = "ALL"
    }
  }
}
