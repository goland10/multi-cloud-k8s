output "nodes_sa_email" {
  description = "Email of the GKE node service account"
  value       = google_service_account.nodes.email
}
