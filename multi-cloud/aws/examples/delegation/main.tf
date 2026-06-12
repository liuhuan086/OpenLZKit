module "delegation" {
  source = "../../modules/delegation"

  name_prefix                          = "lz-"
  enable_ram_sharing_with_organization = true

  delegated_administrators = {
    config = {
      account_id        = "111122223333"
      service_principal = "config.amazonaws.com"
    }
    security_hub = {
      account_id        = "111122223333"
      service_principal = "securityhub.amazonaws.com"
    }
    guardduty = {
      account_id        = "111122223333"
      service_principal = "guardduty.amazonaws.com"
    }
    access_analyzer = {
      account_id        = "111122223333"
      service_principal = "access-analyzer.amazonaws.com"
    }
  }

  resource_shares = {
    shared_network = {
      name       = "shared-network"
      principals = ["arn:aws:organizations::111122223333:ou/o-example/ou-example-workloads"]
      resource_arns = [
        "arn:aws:ec2:us-east-1:111122223333:subnet/subnet-00000000000000001",
      ]
      permission_arns = [
        "arn:aws:ram::aws:permission/AWSRAMDefaultPermissionSubnet",
      ]
    }
  }
}
