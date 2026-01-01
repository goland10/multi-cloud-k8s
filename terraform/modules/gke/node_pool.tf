resource "google_container_node_pool" "primary" {
  name       = "primary-pool"
  location   = var.region
  cluster    = google_container_cluster.this.name
  node_count = 1
  #node_locations = ["me-west1-a", "me-west1-b"]

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    #machine_type = "e2-standard-2"
    machine_type = "e2-medium"      # Minimal stable machine type
    disk_size_gb = 12               # Minimal boot disk size
    # Standard on-demand nodes (no spot/preemptible)

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.environment
    }

    tags = ["gke-node"]

    shielded_instance_config {
      enable_secure_boot = true
      enable_integrity_monitoring = true
    }
  }
}
