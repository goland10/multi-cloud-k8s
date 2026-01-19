#######################################
# Network
#######################################
module "network" {
  source = "./modules/network"

  vpc_name = var.vpc
  region   = var.region

  nodes_cidr    = var.nodes_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr

}

#######################################
# IAM – node service account
#######################################
module "iam" {
  source = "./modules/iam"

  project_id = var.project_id
  env_name   = var.env_name

  node_identity       = var.node_identity
  node_identity_roles = var.node_identity_roles

}

#######################################
# GKE
#######################################

module "gke" {
  source = "./modules/gke"

  # Environment identity
  env_name = var.env_name
  env_type = var.env_type

  # Location
  location       = var.location
  node_locations = var.node_locations
  node_count     = var.node_count

  # Network
  network    = module.network.vpc_name
  subnetwork = module.network.subnet_name

  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name

  # IAM
  node_service_account = module.iam.node_service_account_email

  # Node configuration
  node_instance_type = var.node_instance_type
  node_disk_size_gb  = var.node_disk_size_gb
  node_min           = var.node_min
  node_max           = var.node_max

  # Cluster behavior
  deletion_protection = var.deletion_protection
  release_channel     = var.release_channel

  # Observability
  logging_components    = var.logging_components
  monitoring_components = var.monitoring_components

  # Labels / tags
  labels = var.gcp_labels_aws_tags
}
