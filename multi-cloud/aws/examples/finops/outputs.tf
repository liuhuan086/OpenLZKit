output "budget_ids" {
  description = "Budget ids by key."
  value       = module.finops.budget_ids
}

output "anomaly_monitor_arns" {
  description = "Cost anomaly monitor ARNs by key."
  value       = module.finops.anomaly_monitor_arns
}

output "cur_bucket_names" {
  description = "CUR bucket names by key."
  value       = module.finops.cur_bucket_names
}

output "cur_report_names" {
  description = "CUR report names by key."
  value       = module.finops.cur_report_names
}

output "quicksight_data_source_arns" {
  description = "QuickSight Athena data source ARNs by key."
  value       = module.finops.quicksight_data_source_arns
}

output "quicksight_folder_arns" {
  description = "QuickSight folder ARNs by key."
  value       = module.finops.quicksight_folder_arns
}

output "quicksight_group_arns" {
  description = "QuickSight group ARNs by key."
  value       = module.finops.quicksight_group_arns
}
