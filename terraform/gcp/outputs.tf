#######################################
# Environment identity
#######################################
output "env_name" {
  description = "Environment name"
  value       = var.env_name
}

output "env_type" {
  description = "Environment type"
  value       = var.env_type
}

#######################################
# Network
#######################################
output "vpc_name" {
  description = "VPC network name"
  value       = module.network.vpc_name
}

output "subnetwork_name" {
  description = "Subnetwork name"
  value       = module.network.subnet_name
}

#######################################
# IAM
#######################################
output "node_service_account" {
  description = "Node service account email"
  value       = module.iam.node_service_account_email
}

#######################################
# GKE
#######################################
output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_location" {
  description = "GKE cluster location (region or zone)"
  value       = module.gke.cluster_location
}

output "gke_cluster_endpoint" {
  description = "GKE cluster API endpoint"
  value       = module.gke.endpoint
}

#######################################
# Labels / tags
#######################################
output "gcp_labels_aws_tags" {
  description = "Labels / tags applied to resources"
  value       = local.gcp_labels_aws_tags
}
