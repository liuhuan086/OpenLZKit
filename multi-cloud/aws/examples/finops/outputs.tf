output "budget_ids" {
  description = "Budget ids by key."
  value       = module.finops.budget_ids
}

output "anomaly_monitor_arns" {
  description = "Cost anomaly monitor ARNs by key."
  value       = module.finops.anomaly_monitor_arns
}
