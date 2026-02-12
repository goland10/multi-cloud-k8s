# -------------------------------------------------------------------
# Environment identity
# -------------------------------------------------------------------
#env_name = "staging-01"
#env_type = "staging"
#project_id = "github-actions-terraform-k8s"
#runner_service_account = "github-terraform-k8s"

region = "europe-west1"

# -------------------------------------------------------------------
# Labels / cost allocation
# -------------------------------------------------------------------
owner = "david"

# -------------------------------------------------------------------
# Network
# -------------------------------------------------------------------
vpc           = "staging-01"
nodes_cidr    = "10.11.0.0/16"
pods_cidr     = "10.21.0.0/16"
services_cidr = "10.31.0.0/20"

# -------------------------------------------------------------------
# IAM (node service account)
# -------------------------------------------------------------------
node_identity = "staging-01-node-identity"

node_identity_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/monitoring.viewer",
]

# -------------------------------------------------------------------
# Location
# -------------------------------------------------------------------
#Control plain location.
location = "europe-west1" # region for regional cluster, zone for zonal cluster

#node_locations: worker nodes location
#Only for GKE. 
#Comment 'node_locations', if you want to use all the zones in the region.
#node_locations = ["europe-west1-c","europe-west1-d"]        

# -------------------------------------------------------------------
# GKE node configuration
# -------------------------------------------------------------------
node_instance_type = "e2-standard-4"
node_disk_size_gb  = 30

node_min   = 1
node_max   = 2
node_count = 1

# -------------------------------------------------------------------
# GKE cluster behavior
# -------------------------------------------------------------------
deletion_protection = false
release_channel     = "REGULAR"   # RAPID | REGULAR | STABLE and more

logging_components    = ["SYSTEM_COMPONENTS"]
monitoring_components = ["SYSTEM_COMPONENTS"]