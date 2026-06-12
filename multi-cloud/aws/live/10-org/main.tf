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
      children = {
        log-archive      = { name = "Log Archive" }
        security-tooling = { name = "Security Tooling" }
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
        prod    = { name = "Prod" }
        nonprod = { name = "Nonprod" }
        sandbox = { name = "Sandbox" }
      }
    }
  }
}

module "accounts" {
  source = "../../modules/account-factory"

  ou_ids      = module.org.ou_ids
  accounts    = var.accounts
  common_tags = var.account_common_tags
}
