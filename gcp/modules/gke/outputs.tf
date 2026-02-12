#######################################
# GKE cluster outputs
#######################################

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "cluster_id" {
  description = "Full resource ID of the GKE cluster"
  value       = google_container_cluster.this.id
}

output "cluster_location" {
  description = "Region or zone where the cluster is deployed"
  value       = google_container_cluster.this.location
}

output "endpoint" {
  description = "GKE cluster API endpoint"
  value       = google_container_cluster.this.endpoint
}

output "ca_certificate" {
  description = "Base64-encoded public CA certificate for the cluster"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

#######################################
# Node pool outputs
#######################################

output "node_pool_name" {
  description = "Name of the primary node pool"
  value       = try(google_container_node_pool.primary[0].name, null)
}

output "node_service_account" {
  description = "Service account used by GKE nodes"
  value       = var.env_type == "dev" ? null : var.node_service_account
}

#######################################
# Convenience outputs
#######################################

output "kubeconfig_context" {
  description = "Suggested kubectl context name"
  value       = "${var.env_name}-${var.location}"
}
