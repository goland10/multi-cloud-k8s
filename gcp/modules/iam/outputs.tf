output "node_service_account_email" {
  description = "Email of the GKE node service account"
  value       = google_service_account.nodes.email
}

output "node_service_account_name" {
  description = "Full resource name of the GKE node service account"
  value       = google_service_account.nodes.name
}

output "node_service_account_id" {
  description = "Service account ID (short name)"
  value       = google_service_account.nodes.account_id
}
