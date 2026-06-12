output "audit_project_name" {
  description = "SLS audit project name."
  value       = alicloud_log_project.audit.project_name
}

output "audit_logstore_name" {
  description = "SLS audit logstore name."
  value       = alicloud_log_store.audit.logstore_name
}

output "trail_name" {
  description = "ActionTrail trail name."
  value       = alicloud_actiontrail_trail.audit.trail_name
}
