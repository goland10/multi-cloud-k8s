# -------------------------------------------------------------------
# Environment identity
# -------------------------------------------------------------------
env_name = "dev-01"
env_type = "dev"
project_id = "chatgpt1-goland1"
region     = "europe-west1"

# -------------------------------------------------------------------
# Labels / cost allocation
# -------------------------------------------------------------------
labels_or_tags = {
  env_type    = "dev"   
  env_name    = "dev-01"
  owner       = "david"
  project     = "k8s-terraform"
}

# -------------------------------------------------------------------
# Network
# -------------------------------------------------------------------
vpc           = "dev-01"
nodes_cidr   = "10.10.0.0/16"
pods_cidr     = "10.20.0.0/16"
services_cidr = "10.30.0.0/20"

# -------------------------------------------------------------------
# IAM (node service account)
# -------------------------------------------------------------------
node_identity           = "dev-01-node-identity"

node_identity_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/monitoring.viewer",
]

# -------------------------------------------------------------------
# GKE location
# -------------------------------------------------------------------
location = "europe-west1-b"                 #region_or_zone for GKE
node_locations = ["europe-west1-c"]         #Only for GKE

# -------------------------------------------------------------------
# GKE node configuration
# -------------------------------------------------------------------
node_instance_type = "e2-medium"
node_disk_size_gb = 12

node_min   = 1
node_max   = 2
node_count = 1

# -------------------------------------------------------------------
# GKE cluster behavior
# -------------------------------------------------------------------
deletion_protection = false
release_channel     = "RAPID"

logging_components     = ["SYSTEM_COMPONENTS"]
monitoring_components = []