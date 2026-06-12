module "finops" {
  source = "../../modules/finops"

  budgets               = var.budgets
  anomaly_monitors      = var.anomaly_monitors
  anomaly_subscriptions = var.anomaly_subscriptions
  cost_categories       = var.cost_categories
}
