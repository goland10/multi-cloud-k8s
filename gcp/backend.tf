terraform {
  backend "gcs" {
    bucket = "github-k8s-terraform-state"
  }
}
