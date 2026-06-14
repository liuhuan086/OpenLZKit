output "logset_id" {
  description = "CLS audit logset id."
  value       = tencentcloud_cls_logset.audit.id
}

output "topic_id" {
  description = "CLS audit topic id."
  value       = tencentcloud_cls_topic.audit.id
}

output "audit_track_id" {
  description = "CloudAudit track id."
  value       = tencentcloud_audit_track.audit.id
}
