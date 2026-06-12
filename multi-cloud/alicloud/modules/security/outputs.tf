output "password_policy_id" {
  description = "RAM account password policy id."
  value       = alicloud_ram_account_password_policy.this.id
}

output "security_preference_id" {
  description = "RAM security preference id."
  value       = alicloud_ram_security_preference.this.id
}
