locals {
  gcp_labels_aws_tags = {
    env_type = var.env_type
    env_name = var.env_name
    owner    = var.owner
    project  = "k8s-terraform"
  }
}

##data "google_compute_zones" "this" {
##  region = var.region
##  status = "UP"
##}
##
##resource "random_shuffle" "zone" {
##  input        = data.google_compute_zones.this.names
##  result_count = 1
##
##  keepers = {
##    region = var.region
##  }
##}
##
##locals {
##  all_zones = data.google_compute_zones.this.names
##  node_locations_by_env = {
##    dev     = random_shuffle.zone.result #slice(local.all_zones, 0, 1)
##    staging = slice(local.all_zones, 0, 2)
##    prod    = local.all_zones
##  }
##
##  #node_locations = local.node_locations_by_env[var.environment]
##  node_locations = var.environment == "dev" ? null : local.node_locations_by_env[var.environment]
##  location       = var.environment == "dev" ? local.node_locations_by_env[var.environment][0] : var.region
##}
##
##locals {
##  impersonate_sa = "github-terraform"
##}


#locals {
#  all_zones = data.google_compute_zones.this.names
#
#  node_locations = (
#    var.environment == "dev" ?
#    random_shuffle.zone.result :
#
#    var.environment == "staging" ?
#    slice(local.all_zones, 0, 2) :
#
#    local.all_zones
#  )
#}