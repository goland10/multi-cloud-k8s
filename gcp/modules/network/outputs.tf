#######################################
# Network outputs
#######################################

output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_region" {
  description = "Region of the subnet"
  value       = google_compute_subnetwork.subnet.region
}

#######################################
# Secondary IP ranges (for GKE)
#######################################

output "pods_range_name" {
  description = "Secondary IP range name for GKE pods"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Secondary IP range name for GKE services"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}
