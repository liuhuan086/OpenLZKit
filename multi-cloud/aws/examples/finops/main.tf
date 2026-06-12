module "finops" {
  source = "../../modules/finops"

  budgets = {
    sandbox_monthly = {
      name         = "sandbox-monthly"
      limit_amount = "1000"
      cost_filters = {
        TagKeyValue = ["user:env$sandbox"]
      }
      notifications = [{
        comparison_operator        = "GREATER_THAN"
        threshold                  = 80
        notification_type          = "FORECASTED"
        subscriber_email_addresses = ["cloud-finops@example.invalid"]
      }]
    }
  }

  anomaly_monitors = {
    service = {
      name              = "service-monitor"
      monitor_type      = "DIMENSIONAL"
      monitor_dimension = "SERVICE"
    }
  }

  anomaly_subscriptions = {
    daily = {
      name              = "daily-anomalies"
      frequency         = "DAILY"
      monitor_keys      = ["service"]
      subscriber_emails = ["cloud-finops@example.invalid"]
    }
  }

  cost_categories = {
    business_unit = {
      name = "BusinessUnit"
      rules = [{
        value = "payments"
        dimension = {
          key    = "LINKED_ACCOUNT_NAME"
          values = ["payments-prod", "payments-nonprod"]
        }
      }]
    }
  }
}
