locals {
  environment  = "dev"
  cluster_name = "${local.environment}-${var.region}"
}

module "network" {
  source = "../../modules/network"
  region = var.region
}

module "iam" {
  source = "../../modules/iam"
  account_id = "github-terraform@${var.project_id}.iam.gserviceaccount.com"
}

module "gke" {
  source = "../../modules/gke"

  project_id = var.project_id
  region     = var.region

  cluster_name = local.cluster_name
  environment  = local.environment

  network    = module.network.vpc_id
  subnetwork = module.network.subnet_id

  pods_range_name     = "pods"
  services_range_name = "services"

  service_account = module.iam.google_service_account.gke_nodes.email
}