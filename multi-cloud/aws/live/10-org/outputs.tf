output "root_id" {
  description = "AWS Organizations root id."
  value       = module.org.root_id
}

output "ou_ids" {
  description = "Stable OU keys mapped to AWS Organizations OU ids."
  value       = module.org.ou_ids
}

output "account_ids" {
  description = "Account keys mapped to account ids after apply."
  value       = module.accounts.account_ids
}
