variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "root_node_id" {
  description = "Organization root node id."
  type        = number
}

variable "members" {
  description = "Optional member accounts to create through the account factory. Empty by default (billing impact)."
  type = map(object({
    name           = string
    node_key       = string
    policy_type    = optional(string, "Financial")
    permission_ids = list(number)
    tags           = optional(map(string), {})
  }))
  default = {}
}

provider "tencentcloud" {
  region = var.region
}

# 10-org: organization node hierarchy mirroring the account model.
module "org" {
  source       = "../../modules/org"
  name_prefix  = "lz-"
  root_node_id = var.root_node_id

  nodes = {
    security = {
      name = "Security"
      children = {
        audit-log      = { name = "Audit Log" }
        security-tools = { name = "Security Tooling" }
      }
    }
    infrastructure = {
      name = "Infrastructure"
      children = {
        network         = { name = "Network" }
        shared-services = { name = "Shared Services" }
      }
    }
    workloads = {
      name = "Workloads"
      children = {
        prod = { name = "Prod" }
        dev  = { name = "Dev" }
      }
    }
    sandbox = {
      name = "Sandbox"
    }
  }
}

# Member-account vending wired here but disabled by default (billing impact).
module "accounts" {
  source      = "../../modules/account-factory"
  common_tags = { managed_by = "terraform" }

  members = {
    for key, m in var.members :
    key => {
      name           = m.name
      node_id        = tonumber(module.org.node_ids[m.node_key])
      policy_type    = m.policy_type
      permission_ids = m.permission_ids
      tags           = m.tags
    }
  }
}

output "node_ids" {
  value = module.org.node_ids
}

output "member_ids" {
  value = module.accounts.member_ids
}
