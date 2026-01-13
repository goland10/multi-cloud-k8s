module "network" {
  source = "../../modules/network"
  region = var.region
}

module "iam" {
  source     = "../../modules/iam"
  account_id = "${local.impersonate_sa}@${var.project_id}.iam.gserviceaccount.com"
}
