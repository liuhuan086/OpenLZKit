module "finops" {
  source = "../../modules/finops"

  budgets                        = var.budgets
  anomaly_monitors               = var.anomaly_monitors
  anomaly_subscriptions          = var.anomaly_subscriptions
  cost_categories                = var.cost_categories
  cur_buckets                    = var.cur_buckets
  cur_reports                    = var.cur_reports
  quicksight_athena_data_sources = var.quicksight_athena_data_sources
  quicksight_folders             = var.quicksight_folders
  quicksight_groups              = var.quicksight_groups
  common_tags                    = var.common_tags
}
