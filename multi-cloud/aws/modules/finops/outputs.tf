output "budget_ids" {
  description = "Budget ids by key."
  value       = { for key, budget in aws_budgets_budget.this : key => budget.id }
}

output "anomaly_monitor_arns" {
  description = "Cost anomaly monitor ARNs by key."
  value       = { for key, monitor in aws_ce_anomaly_monitor.this : key => monitor.arn }
}

output "anomaly_subscription_arns" {
  description = "Cost anomaly subscription ARNs by key."
  value       = { for key, subscription in aws_ce_anomaly_subscription.this : key => subscription.arn }
}

output "cost_category_arns" {
  description = "Cost category ARNs by key."
  value       = { for key, category in aws_ce_cost_category.this : key => category.arn }
}

output "cur_bucket_names" {
  description = "CUR bucket names by key."
  value       = { for key, bucket in aws_s3_bucket.cur : key => bucket.bucket }
}

output "cur_report_names" {
  description = "CUR report names by key."
  value       = { for key, report in aws_cur_report_definition.this : key => report.report_name }
}

output "quicksight_data_source_arns" {
  description = "QuickSight Athena data source ARNs by key."
  value       = { for key, data_source in aws_quicksight_data_source.athena : key => data_source.arn }
}

output "quicksight_folder_arns" {
  description = "QuickSight folder ARNs by key."
  value       = { for key, folder in aws_quicksight_folder.this : key => folder.arn }
}

output "quicksight_group_arns" {
  description = "QuickSight group ARNs by key."
  value       = { for key, group in aws_quicksight_group.this : key => group.arn }
}
