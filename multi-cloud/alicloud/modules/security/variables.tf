variable "minimum_password_length" {
  description = "Minimum RAM password length."
  type        = number
  default     = 14
}

variable "max_password_age" {
  description = "Maximum password age in days (0 = no expiry)."
  type        = number
  default     = 90
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords that cannot be reused."
  type        = number
  default     = 5
}

variable "max_login_attempts" {
  description = "Max failed login attempts before lockout."
  type        = number
  default     = 5
}

variable "mfa_operation_for_login" {
  description = "MFA requirement for RAM console login. \"mandatory\" enforces MFA for all users."
  type        = string
  default     = "mandatory"
}

variable "allow_user_to_manage_access_keys" {
  description = "Allow RAM users to manage their own AccessKeys. Off by default (prefer short-lived credentials)."
  type        = bool
  default     = false
}

variable "login_session_duration" {
  description = "Console login session duration in hours."
  type        = number
  default     = 6
}
