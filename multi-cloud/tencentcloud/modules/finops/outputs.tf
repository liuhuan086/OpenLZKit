output "allocation_tag_keys" {
  description = "Tag keys enabled for cost allocation."
  value       = [for t in tencentcloud_billing_allocation_tag.this : t.tag_key]
}

output "budget_ids" {
  description = "Map of budget key to id."
  value       = { for k, b in tencentcloud_billing_budget.this : k => b.id }
}
