variable "defender_plans" {
  description = <<-EOT
    Microsoft Defender for Cloud plans keyed by resource type
    (e.g. "VirtualMachines", "StorageAccounts", "KeyVaults"). Entries always
    enable the Standard tier; omit a resource type instead of setting Free.
  EOT
  type = map(object({
    subplan = optional(string)
  }))
  default = {}
}

variable "security_contact" {
  description = "Security contact for Defender alerts. Null to skip."
  type = object({
    name                = string
    email               = string
    phone               = optional(string, "")
    alert_notifications = optional(bool, true)
    alerts_to_admins    = optional(bool, true)
  })
  default = null
}
