module "iam" {
  source     = "./modules/iam"
  account_id = "${local.impersonate_sa}@${var.project_id}.iam.gserviceaccount.com"
}

module "gke" {
  source = "./modules/gke"

  environment = var.environment
  #region         = var.region
  location       = local.location
  node_locations = local.node_locations

  cluster_name = var.cluster_name

  network             = module.network.vpc_id
  subnetwork          = module.network.subnet_id
  pods_range_name     = module.network.pods_range_name     #"pods"
  services_range_name = module.network.services_range_name #"services"

  machine_type = var.machine_type
  disk_size_gb = var.disk_size_gb
  node_min     = var.node_min
  node_max     = var.node_max
  node_count   = var.node_count

  deletion_protection = var.deletion_protection
  service_account     = module.iam.nodes_SA-email

  release_channel       = var.release_channel
  logging_components    = var.logging_components
  monitoring_components = var.monitoring_components
}
