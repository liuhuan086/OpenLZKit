resource "tencentcloud_cls_logset" "audit" {
  logset_name = "${var.name_prefix}${var.logset_name}"
  tags        = var.tags
}

resource "tencentcloud_cls_topic" "audit" {
  logset_id       = tencentcloud_cls_logset.audit.id
  topic_name      = "${var.name_prefix}${var.topic_name}"
  period          = var.period
  partition_count = 1
  tags            = var.tags
}

# CloudAudit track delivering management events to the CLS topic.
resource "tencentcloud_audit_track" "audit" {
  name                  = "${var.name_prefix}audit"
  action_type           = var.audit_action_type
  event_names           = ["*"]
  resource_type         = "*"
  status                = 1
  track_for_all_members = var.track_for_all_members ? 1 : 0

  storage {
    storage_type   = "cls"
    storage_region = var.region
    storage_name   = tencentcloud_cls_topic.audit.id
    storage_prefix = "cloudaudit"
  }
}
