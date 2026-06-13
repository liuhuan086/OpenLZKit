variable "project_id" {
  description = "Platform/automation project id that owns the CI service account."
  type        = string
}

variable "workload_identity_pool_name" {
  description = "Full WIF pool resource name from 00-bootstrap (iam.googleapis.com/projects/.../workloadIdentityPools/...)."
  type        = string
}

variable "github_owner" {
  description = "GitHub org/user for the CI principalSet."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository for the CI principalSet."
  type        = string
}

variable "project_bindings" {
  description = "Cross-project IAM grants for the CI deployer SA. Empty by default."
  type = map(object({
    project = string
    role    = string
  }))
  default = {}
}

provider "google" {
  project = var.project_id
}

# 24-cross-account-access: a CI deployer service account impersonated by the
# repo's federated identity (no key), granted least-privilege cross-project roles.
module "cross_account" {
  source = "../../modules/cross-account-access"

  service_accounts = {
    cicd-deployer = {
      account_id   = "lz-cicd-deployer"
      project      = var.project_id
      display_name = "CI/CD deployer (WIF)"
    }
  }

  wif_bindings = {
    github = {
      service_account_key = "cicd-deployer"
      member              = "principalSet://iam.googleapis.com/${var.workload_identity_pool_name}/attribute.repository/${var.github_owner}/${var.github_repo}"
    }
  }

  project_bindings = {
    for key, b in var.project_bindings :
    key => {
      project             = b.project
      role                = b.role
      service_account_key = "cicd-deployer"
    }
  }
}

output "cicd_service_account_email" {
  value = module.cross_account.service_account_emails["cicd-deployer"]
}
