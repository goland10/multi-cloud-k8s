terraform {
  backend "gcs" {
    bucket  = "gke-github_actions-state"
  }
}
