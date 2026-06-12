module "compliance" {
  source = "../../modules/compliance"

  enable_security_hub           = var.enable_security_hub
  security_hub_admin_account_id = var.security_hub_admin_account_id
  security_hub_standards        = var.security_hub_standards
  enable_guardduty_detector     = var.enable_guardduty_detector
  guardduty_admin_account_id    = var.guardduty_admin_account_id
  config_aggregators            = var.config_aggregators
  config_managed_rules          = var.config_managed_rules
  conformance_packs             = var.conformance_packs
}
