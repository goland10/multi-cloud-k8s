#######################################
# Network
#######################################

module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name
  subnets      = var.subnets
}

#######################################
# IAM
#######################################

module "iam" {
  source      = "./modules/iam"
  project_id  = var.project_id
  nodes_sa_id = var.nodes_sa_id
}

#######################################
# GKE Clusters
#######################################

module "gke" {
  source   = "./modules/gke"
  for_each = var.clusters

  # Naming
  cluster_name = "${each.key}"
  environment  = each.value.environment

  # Location
  location       = each.value.region_or_zone
  node_locations = lookup(each.value, "node_locations", null)

  # Networking
  network_name    = module.network.network_name
  subnetwork_name = module.network.subnet_names[each.key]

  # Node pool sizing
  machine_type = each.value.machine_type
  disk_size_gb = each.value.disk_size_gb

  node_min   = each.value.node_min
  node_max   = each.value.node_max
  node_count = each.value.node_count

  # Cluster behavior
  deletion_protection = each.value.deletion_protection
  release_channel     = each.value.release_channel

  logging_components     = each.value.logging_components
  monitoring_components = each.value.monitoring_components

  # Identity
  service_account = module.iam.nodes_sa_email

}
