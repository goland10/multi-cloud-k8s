data "google_client_config" "current" {}

#######################################
# GKE Cluster
#######################################

resource "google_container_cluster" "this" {
  name     = var.env_name

  # Location
  location = var.location
  node_locations = var.node_locations

  # Networking
  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Default node config (dev only)
  node_config {
    machine_type    = var.node_instance_type
    disk_size_gb    = var.node_disk_size_gb
    service_account = var.node_service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    resource_labels = var.labels
  }

  # Identity
  workload_identity_config {
    workload_pool = "${data.google_client_config.current.project}.svc.id.goog"
  }

# Cluster behavior
  deletion_protection     = var.deletion_protection
  remove_default_node_pool = var.env_type != "dev"
  initial_node_count       = var.env_type == "dev" ? var.node_count : 1

  release_channel {
    channel = var.release_channel
  }
  
  # Observability
  logging_config {
    enable_components = var.logging_components
  }

  monitoring_config {
    enable_components = var.monitoring_components
  }

  resource_labels = var.labels
}

#######################################
# GKE Node Pool (staging / prod)
#######################################

resource "google_container_node_pool" "primary" {
  count = var.env_type == "dev" ? 0 : 1

  name     = "primary-pool"
  cluster = google_container_cluster.this.name
  location = var.location
  node_locations = var.node_locations

  # Scaling
  node_count = var.node_count

  autoscaling {
    min_node_count = var.node_min
    max_node_count = var.node_max
  }

  # Node configuration
  node_config {
    machine_type    = var.node_instance_type
    disk_size_gb    = var.node_disk_size_gb
    service_account = var.node_service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    resource_labels = var.labels

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  # Node pool management
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
