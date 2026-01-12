terraform {
  backend "gcs" {
    bucket = "github_actions-gke-terraform-state"
  }
}
