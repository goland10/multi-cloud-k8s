data "google_service_account" "github_terraform" {
  account_id = var.account_id
}

resource "google_service_account" "nodes_SA" {
  account_id   = "gke-nodes"
  display_name = "GKE Nodes"
}

resource "google_service_account_iam_member" "impersonate_gke_nodes" {
  service_account_id = google_service_account.nodes_SA.name
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${data.google_service_account.github_terraform.email}"
}
