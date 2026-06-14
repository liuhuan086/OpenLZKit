output "scan_task_ids" {
  description = "Map of scan task key to id."
  value       = { for k, t in tencentcloud_csip_risk_center.this : k => t.id }
}
