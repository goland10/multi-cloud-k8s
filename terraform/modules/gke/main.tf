resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork
  deletion_protection = false
  remove_default_node_pool = true
  initial_node_count       = 1
  
  node_config {
    #machine_type = "e2-medium"
    disk_size_gb = 12
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
