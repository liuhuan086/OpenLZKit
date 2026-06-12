module "org" {
  source = "../../modules/org"

  name_prefix = "lz-"

  tags = {
    managed_by = "terraform"
    project    = "openlzkit"
  }

  organizational_units = {
    security = {
      name = "Security"
      tags = {
        owner       = "security-platform"
        cost_center = "platform-security"
      }
      children = {
        log-archive = {
          name = "Log Archive"
          tags = {
            owner       = "security-platform"
            cost_center = "platform-security"
          }
        }
        security-tooling = {
          name = "Security Tooling"
          tags = {
            owner       = "security-platform"
            cost_center = "platform-security"
          }
        }
      }
    }

    infrastructure = {
      name = "Infrastructure"
      tags = {
        owner       = "platform-engineering"
        cost_center = "platform-network"
      }
      children = {
        network = {
          name = "Network"
          tags = {
            owner       = "platform-engineering"
            cost_center = "platform-network"
          }
        }
        shared-services = {
          name = "Shared Services"
          tags = {
            owner       = "platform-engineering"
            cost_center = "platform-shared"
          }
        }
      }
    }

    workloads = {
      name = "Workloads"
      tags = {
        owner       = "platform-engineering"
        cost_center = "business-shared"
      }
      children = {
        prod = {
          name = "Prod"
          tags = {
            owner       = "platform-engineering"
            cost_center = "business-prod"
          }
        }
        nonprod = {
          name = "Nonprod"
          tags = {
            owner       = "platform-engineering"
            cost_center = "business-nonprod"
          }
        }
        sandbox = {
          name = "Sandbox"
          tags = {
            owner       = "platform-engineering"
            cost_center = "business-sandbox"
          }
        }
      }
    }
  }
}
