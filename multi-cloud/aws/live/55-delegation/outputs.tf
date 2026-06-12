output "delegated_administrator_ids" {
  description = "Organizations delegated administrator ids by key."
  value       = module.delegation.delegated_administrator_ids
}

output "ram_resource_share_arns" {
  description = "AWS RAM resource share ARNs by key."
  value       = module.delegation.ram_resource_share_arns
}
