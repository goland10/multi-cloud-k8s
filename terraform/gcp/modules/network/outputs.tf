output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_names" {
  description = "Subnet names keyed by environment"
  value = {
    for k, subnet in google_compute_subnetwork.subnets :
    k => subnet.name
  }
}

output "subnet_self_links" {
  description = "Subnet self links keyed by environment"
  value = {
    for k, subnet in google_compute_subnetwork.subnets :
    k => subnet.self_link
  }
}

output "secondary_ip_ranges" {
  description = "Secondary IP range names for each subnet"
  value = {
    for k, subnet in google_compute_subnetwork.subnets :
    k => {
      pods     = "pods"
      services = "services"
    }
  }
}
