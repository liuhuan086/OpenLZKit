variable "project_id" {
  description = "Project id for the provider."
  type        = string
}

variable "customer_id" {
  description = "Cloud Identity customer id (\"customers/C0xxxxxxx\")."
  type        = string
}

variable "domain" {
  description = "Cloud Identity primary domain for group emails (e.g. example.com)."
  type        = string
}

variable "org_folder" {
  description = "Org root folder (\"folders/<id>\") where platform personas are granted access."
  type        = string
}

provider "google" {
  project = var.project_id
}

# 25-sso: human access via Cloud Identity groups + IAM at folder scope. People
# are added to groups via the IdP; groups (not users) receive roles.
module "groups" {
  source      = "../../modules/identity-groups"
  customer_id = var.customer_id

  groups = {
    platform-admins   = { email = "lz-platform-admins@${var.domain}", display_name = "LZ Platform Admins" }
    security-auditors = { email = "lz-security-auditors@${var.domain}", display_name = "LZ Security Auditors" }
  }

  folder_bindings = {
    platform-admins = {
      group_key = "platform-admins"
      folder    = var.org_folder
      role      = "roles/editor"
    }
    security-auditors = {
      group_key = "security-auditors"
      folder    = var.org_folder
      role      = "roles/viewer"
    }
  }
}

output "group_emails" {
  value = module.groups.group_emails
}
