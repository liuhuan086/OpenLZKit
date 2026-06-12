output "role_names" {
  description = "Cross-account IAM role names by key."
  value       = { for key, role in aws_iam_role.cross_account : key => role.name }
}

output "role_arns" {
  description = "Cross-account IAM role ARNs by key."
  value       = { for key, role in aws_iam_role.cross_account : key => role.arn }
}

output "oidc_provider_arns" {
  description = "OIDC provider ARNs by key."
  value       = { for key, provider in aws_iam_openid_connect_provider.this : key => provider.arn }
}

output "resource_share_arns" {
  description = "AWS RAM resource share ARNs by key."
  value       = { for key, share in aws_ram_resource_share.this : key => share.arn }
}
