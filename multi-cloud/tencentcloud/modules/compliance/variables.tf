variable "scan_tasks" {
  description = <<-EOT
    CSIP (Cloud Security Center) risk-scan tasks keyed by stable id. `scan_item`
    is the set of checks (e.g. port, poc, weakpass, configrisk); the numeric
    fields select asset type / plan type / mode per the CSIP API.
  EOT
  type = map(object({
    task_name         = string
    scan_asset_type   = number
    scan_item         = list(string)
    scan_plan_type    = number
    scan_plan_content = optional(string)
    task_mode         = optional(number)
  }))
  default = {}
}
