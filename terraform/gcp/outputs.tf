#######################################
# Project
#######################################

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "Default GCP region"
  value       = var.region
}

#######################################
# Network
#######################################

output "network_name" {
  description = "VPC network name"
  value       = module.network.network_name
}

output "subnet_names" {
  description = "Created subnet names"
  value       = module.network.subnet_names
}

output "subnet_self_links" {
  description = "Subnet self-links keyed by environment"
  value       = module.network.subnet_self_links
}

#######################################
# IAM
#######################################

output "nodes_service_account_email" {
  description = "Service account email used by GKE nodes"
  value       = module.iam.nodes_sa_email
}

#######################################
# GKE
#######################################

output "gke_clusters" {
  description = "GKE cluster details keyed by cluster name"
  value = {
    for name, mod in module.gke :
    name => {
      name     = mod.cluster_name
      location = mod.location
      endpoint = mod.cluster_endpoint
    }
  }
}

#output "gke_cluster_ids" {
#  description = "GKE cluster IDs keyed by cluster name"
#  value = {
#    for name, mod in module.gke :
#    name => mod.cluster_id
#  }
#}
