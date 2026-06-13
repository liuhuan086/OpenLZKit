output "budget_ids" {
  description = "Map of budget key to its resource id."
  value       = { for k, b in google_billing_budget.this : k => b.id }
}
