variable "project_id" {
  description = "Project id for the provider."
  type        = string
}

variable "org_id" {
  description = "Organization id (numeric) where guardrail policies are applied."
  type        = string
}

variable "allowed_location_groups" {
  description = "Allowed resource location value groups for gcp.resourceLocations."
  type        = list(string)
  default     = ["in:us-locations", "in:eu-locations"]
}

provider "google" {
  project = var.project_id
}

# 40-security: organization guardrails as Organization Policy (deny by default).
module "org_policies" {
  source = "../../modules/org-policies"
  parent = "organizations/${var.org_id}"

  boolean_policies = {
    disable-sa-key-creation = { constraint = "constraints/iam.disableServiceAccountKeyCreation" }
    skip-default-network    = { constraint = "constraints/compute.skipDefaultNetworkCreation" }
    require-os-login        = { constraint = "constraints/compute.requireOsLogin" }
    uniform-bucket-access   = { constraint = "constraints/storage.uniformBucketLevelAccess" }
  }

  list_policies = {
    allowed-locations = {
      constraint     = "constraints/gcp.resourceLocations"
      allowed_values = var.allowed_location_groups
    }
    deny-vm-external-ip = {
      constraint = "constraints/compute.vmExternalIpAccess"
      deny_all   = true
    }
  }
}

output "boolean_policy_ids" {
  value = module.org_policies.boolean_policy_ids
}
