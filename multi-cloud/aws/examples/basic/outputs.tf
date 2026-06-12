output "ou_ids" {
  description = "Stable OU keys mapped to AWS Organizations OU ids."
  value       = module.org.ou_ids
}
