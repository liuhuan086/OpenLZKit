variable "project_id" {
  description = "Project id for the provider (seed/platform project)."
  type        = string
}

variable "org_id" {
  description = "Organization id (numeric) hosting the folder hierarchy."
  type        = string
}

variable "projects" {
  description = "Optional projects to create through the project factory. Empty by default (billing impact)."
  type = map(object({
    name                = string
    project_id          = string
    folder_key          = string
    billing_account     = optional(string)
    auto_create_network = optional(bool, false)
    labels              = optional(map(string), {})
  }))
  default = {}
}

provider "google" {
  project = var.project_id
}

# 10-org: folder hierarchy mirroring the GCP CAF resource model.
module "org" {
  source      = "../../modules/org"
  name_prefix = "lz-"
  parent      = "organizations/${var.org_id}"

  folders = {
    common = {
      display_name = "Common"
      children = {
        logging    = { display_name = "Logging" }
        monitoring = { display_name = "Monitoring" }
        security   = { display_name = "Security" }
      }
    }
    networking = {
      display_name = "Networking"
    }
    workloads = {
      display_name = "Workloads"
      children = {
        prod = { display_name = "Prod" }
        dev  = { display_name = "Dev" }
      }
    }
    sandbox = {
      display_name = "Sandbox"
    }
  }
}

# Project vending wired here but disabled by default. Enable only after billing
# and naming approvals are complete.
module "projects" {
  source = "../../modules/project-factory"

  common_labels = { managed_by = "terraform" }

  projects = {
    for key, p in var.projects :
    key => {
      name                = p.name
      project_id          = p.project_id
      folder_id           = module.org.folder_names[p.folder_key]
      billing_account     = p.billing_account
      auto_create_network = p.auto_create_network
      labels              = p.labels
    }
  }
}

output "folder_names" {
  value = module.org.folder_names
}

output "project_ids" {
  value = module.projects.project_ids
}
