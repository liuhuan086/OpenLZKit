# Account-wide RAM password policy. Strong character requirements are always on;
# length / age / reuse / lockout are tunable.
resource "alicloud_ram_account_password_policy" "this" {
  minimum_password_length      = var.minimum_password_length
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers              = true
  require_symbols              = true
  max_password_age             = var.max_password_age
  password_reuse_prevention    = var.password_reuse_prevention
  max_login_attempts           = var.max_login_attempts
}

# Account-wide RAM security preference: enforce MFA, discourage user-managed
# AccessKeys, bound session length.
resource "alicloud_ram_security_preference" "this" {
  mfa_operation_for_login          = var.mfa_operation_for_login
  allow_user_to_manage_access_keys = var.allow_user_to_manage_access_keys
  allow_user_to_manage_mfa_devices = true
  allow_user_to_change_password    = true
  login_session_duration           = var.login_session_duration
}
