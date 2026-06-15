module "accounts" {
  source = "../../modules/account-factory"

  ou_ids = {
    "workloads/nonprod" = "ou-example-nonprod"
  }

  accounts = {
    payment_dev = {
      name   = "payment-dev"
      email  = "aws-payment-dev@example.com"
      ou_key = "workloads/nonprod"
      tags = {
        owner               = "payments-platform"
        cost_center         = "cc-1001"
        env                 = "dev"
        project             = "payment"
        data_classification = "internal"
      }
    }
  }
}
