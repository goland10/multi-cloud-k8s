output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "cluster_location" {
  value = google_container_cluster.this.location
}

#output "cluster_endpoint" {
#  value = google_container_cluster.this.endpoint
#}