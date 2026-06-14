output "node_ids" {
  description = "Map of node key (top-level and \"<parent>/<child>\") to its node id."
  value       = local.node_ids
}
