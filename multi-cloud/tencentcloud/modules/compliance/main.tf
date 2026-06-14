resource "tencentcloud_csip_risk_center" "this" {
  for_each = var.scan_tasks

  task_name         = each.value.task_name
  scan_asset_type   = each.value.scan_asset_type
  scan_item         = each.value.scan_item
  scan_plan_type    = each.value.scan_plan_type
  scan_plan_content = each.value.scan_plan_content
  task_mode         = each.value.task_mode
}
