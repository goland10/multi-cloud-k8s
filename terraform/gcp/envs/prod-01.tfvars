# -------------------------------------------------------------------
# Environment identity
# -------------------------------------------------------------------
#env_type = "dev"
#env_number = 01
#env_name = "dev-01"
#project_id = "github-actions-terraform-k8s"
#runner_service_account = "github-terraform-k8s"

region = "europe-west1"

# -------------------------------------------------------------------
# Labels / cost allocation
# -------------------------------------------------------------------
owner = "yaniv"

# -------------------------------------------------------------------
# Network
# -------------------------------------------------------------------
#vpc           = "dev-01"
nodes_cidr    = "10.14.0.0/16"    #This is the base cidr
#pods_cidr     = "10.24.0.0/16"   #base cidr second octet + 10
#services_cidr = "10.34.0.0/20"   #base cidr second octet + 20

# -------------------------------------------------------------------
# IAM (node service account)
# -------------------------------------------------------------------
#node_identity = "dev-01-node-identity"

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
#node_locations = ["europe-west1-c"] #,"europe-west1-d"]        

private_cluster = true

# -------------------------------------------------------------------
# GKE node configuration
# -------------------------------------------------------------------
node_instance_type = "n2-standard-4"  # e2-medium | e2-standard-4 | n2-standard-4
node_disk_size_gb  = 50           # 20 | 30 | 50

node_min   = 1
node_max   = 3
node_count = 1

# -------------------------------------------------------------------
# GKE cluster behavior
# -------------------------------------------------------------------
deletion_protection = true
release_channel     = "STABLE"   # RAPID | REGULAR | STABLE and more

logging_components    = ["SYSTEM_COMPONENTS"]   # "SYSTEM_COMPONENTS"
monitoring_components = ["SYSTEM_COMPONENTS"]   # "SYSTEM_COMPONENTS"