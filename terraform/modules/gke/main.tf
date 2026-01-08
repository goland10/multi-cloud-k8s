data "google_service_account" "github_terraform" {
  account_id = "github-terraform@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes"
  display_name = "GKE Nodes"
}

resource "google_service_account_iam_member" "impersonate_gke_nodes" {
  service_account_id = google_service_account.gke_nodes.name
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${data.google_service_account.github_terraform.email}"
}

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork
  deletion_protection = false

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  
  node_config {
    machine_type = "e2-medium"      # Minimal stable machine type
    disk_size_gb = 12               # Minimal boot disk size
    service_account = google_service_account.gke_nodes.email
  }
  
  timeouts {
    create = "15m"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  release_channel {
    channel = "REGULAR"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
}

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
    # Standard on-demand nodes (no spot/preemptible) to avoid instability
    machine_type = "e2-medium"      # Minimal stable machine type
    disk_size_gb = 12               # Minimal boot disk size
    service_account = google_service_account.gke_nodes.email
    
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