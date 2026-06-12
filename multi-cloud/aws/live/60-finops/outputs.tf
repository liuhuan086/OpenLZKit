output "budget_ids" {
  description = "Budget ids by key."
  value       = module.finops.budget_ids
}

output "anomaly_monitor_arns" {
  description = "Cost anomaly monitor ARNs by key."
  value       = module.finops.anomaly_monitor_arns
}

output "cost_category_arns" {
  description = "Cost category ARNs by key."
  value       = module.finops.cost_category_arns
}

output "cur_bucket_names" {
  description = "CUR bucket names by key."
  value       = module.finops.cur_bucket_names
}

output "cur_report_names" {
  description = "CUR report names by key."
  value       = module.finops.cur_report_names
}
