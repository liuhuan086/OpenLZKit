output "policy_id" {
  description = "Created tag policy id."
  value       = alicloud_tag_policy.required_tags.id
}

output "required_tag_keys" {
  description = "Tag keys enforced by the policy."
  value       = var.required_tag_keys
}
