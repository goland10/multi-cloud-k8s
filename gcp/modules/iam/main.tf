resource "google_service_account" "nodes" {
  account_id   = var.node_identity
  display_name = "GKE nodes service account (${var.env_name})"
}

# Grant roles to the node SA
resource "google_project_iam_member" "nodes_roles" {
  for_each = toset(var.node_identity_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

data "google_service_account" "runner" {
  account_id = var.runner_service_account
  project    = var.project_id
}


# Allow the runner SA to attach the node SA to the nodes
resource "google_service_account_iam_member" "runner_can_use_node_sa" {
  service_account_id = google_service_account.nodes.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_service_account.runner.email}"
}
