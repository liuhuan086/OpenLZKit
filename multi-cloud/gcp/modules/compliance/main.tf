resource "google_scc_organization_scc_big_query_export" "this" {
  for_each = var.bigquery_exports

  big_query_export_id = each.value.export_id
  organization        = var.organization
  dataset             = each.value.dataset
  description         = each.value.description
  filter              = each.value.filter
}

resource "google_scc_notification_config" "this" {
  for_each = var.notification_configs

  config_id    = each.value.config_id
  organization = var.organization
  pubsub_topic = each.value.pubsub_topic
  description  = each.value.description

  streaming_config {
    filter = each.value.filter
  }
}
