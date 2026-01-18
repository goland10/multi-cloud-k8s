data "google_client_config" "current" {}

#######################################
# GKE Cluster
#######################################

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  #location = var.region
  location = var.location

  network    = var.network
  subnetwork = var.subnetwork

  deletion_protection = var.deletion_protection

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  node_locations = var.node_locations

  # Required only to satisfy API when removing default node pool
  node_config {
    machine_type = "e2-medium"        #Minimal value
    disk_size_gb    = 12              #Minimal value
    
    service_account = var.service_account
  }

  workload_identity_config {
    # Project-scoped Workload Identity (best practice)
    workload_pool = "${data.google_client_config.current.project}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  release_channel {
    channel = var.release_channel
  }

  logging_config {
    enable_components = var.logging_components
  }

  monitoring_config {
    enable_components = var.monitoring_components
  }

 # timeouts {
 #   create = "15m"
 #   update = "15m"
 #   delete = "15m"
 # }
}

#######################################
# Primary Node Pool
#######################################

resource "google_container_node_pool" "primary" {
  name     = "primary-pool"
  cluster = google_container_cluster.this.name
  #location = var.region
  location = var.location

  node_locations = var.node_locations
  node_count     = var.node_count

  autoscaling {
    min_node_count = var.node_min
    max_node_count = var.node_max
  }

  node_config {
    # Standard on-demand nodes (no spot/preemptible) to avoid instability
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    service_account = var.service_account

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.environment
    }

    tags = ["gke-node"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  #timeouts {
  #  create = "20m"
  #  update = "20m"
  #  delete = "20m"
  #}
}
