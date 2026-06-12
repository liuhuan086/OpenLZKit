output "delegated_administrator_ids" {
  description = "Organizations delegated administrator ids by key."
  value       = { for key, admin in aws_organizations_delegated_administrator.this : key => admin.id }
}

output "ram_resource_share_arns" {
  description = "AWS RAM resource share ARNs by key."
  value       = { for key, share in aws_ram_resource_share.this : key => share.arn }
}

output "ram_sharing_with_organization_enabled" {
  description = "Whether AWS RAM sharing with Organizations is enabled by this module."
  value       = var.enable_ram_sharing_with_organization
}
