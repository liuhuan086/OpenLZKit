output "policy_ids" {
  description = "Organizations policy ids by stable key."
  value       = module.org_policies.policy_ids
}

output "attachment_ids" {
  description = "Organizations policy attachment ids by stable key."
  value       = module.org_policies.attachment_ids
}
