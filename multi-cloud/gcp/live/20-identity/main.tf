variable "project_id" {
  description = "Project id for the provider."
  type        = string
}

variable "org_id" {
  description = "Organization id (numeric) where custom roles are defined."
  type        = string
}

variable "folder_bindings" {
  description = "Optional folder IAM bindings. Empty by default (members are environment-specific)."
  type = map(object({
    folder = string
    role   = string
    member = string
  }))
  default = {}
}

provider "google" {
  project = var.project_id
}

# 20-identity: least-privilege custom org roles for platform personas. Bindings
# to Cloud Identity groups are supplied per environment via folder_bindings.
module "identity" {
  source = "../../modules/identity"
  org_id = var.org_id

  custom_org_roles = {
    lzPlatformOperator = {
      title       = "LZ Platform Operator"
      description = "Operate platform infrastructure without managing IAM or org policy."
      permissions = [
        "compute.networks.get",
        "compute.subnetworks.get",
        "resourcemanager.projects.get",
        "logging.logEntries.list",
      ]
    }
    lzSecurityAuditor = {
      title       = "LZ Security Auditor"
      description = "Read-only access for security and audit."
      permissions = [
        "resourcemanager.projects.get",
        "resourcemanager.folders.get",
        "logging.logEntries.list",
        "iam.roles.get",
      ]
    }
  }

  folder_bindings = var.folder_bindings
}

output "custom_role_ids" {
  value = module.identity.custom_role_ids
}
