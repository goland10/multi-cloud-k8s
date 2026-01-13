output "cluster_name" {
  value = module.gke.cluster_name
}

output "debug_env" {
  value = var.environment
}

output "debug_location" {
  value = local.location
}

output "debug_node_locations" {
  value = local.node_locations
}