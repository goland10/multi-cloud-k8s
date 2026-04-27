# -------------------------------------------------------------------
# Environment identity
# -------------------------------------------------------------------
env_type = "dev"
env_number = 01
#env_name = "dev-01"

region = "eu-west-1"

# -------------------------------------------------------------------
# Labels / cost allocation
# -------------------------------------------------------------------
owner = "yaniv"

# -------------------------------------------------------------------
# Network
# -------------------------------------------------------------------
#vpc           = "dev-01"
vpc_cidr    = "10.10.0.0/16"    #This is the base cidr
#pods_cidr     = "10.20.0.0/16"   #base cidr second octet + 10
#services_cidr = "10.30.0.0/20"   #base cidr second octet + 20

# -------------------------------------------------------------------
# IAM (node role)
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Location
# -------------------------------------------------------------------
# Control plain node location
azs_masters = ["eu-west-1a", "eu-west-1b"]              #At least 2 AZs
private_cluster = true

# Worker node location
azs_workers = ["eu-west-1a","eu-west-1b","eu-west-1c"]  # 1 AZ for single-node cluster, 2 AZs for dual-zone cluster, 3 AZs for multi-zone cluster
# -------------------------------------------------------------------
# EKS Worker node configuration
# -------------------------------------------------------------------
instance_types           = ["t3.small"]
min_size     = 2
max_size     = 6
desired_size = 2
#release_version = "1.33.0-20250704"
#node_instance_type = "e2-standard-4"  # e2-medium | e2-standard-4 | n2-standard-4
#node_disk_size_gb  = 30           # 20 | 30 | 50
#

# -------------------------------------------------------------------
# GKE cluster behavior
# -------------------------------------------------------------------
kubernetes_version = "1.35"

#deletion_protection = false
#release_channel     = "RAPID"   # RAPID | REGULAR | STABLE and more
#
#logging_components    = ["SYSTEM_COMPONENTS"]   # "SYSTEM_COMPONENTS"
#monitoring_components = ["SYSTEM_COMPONENTS"]   # "SYSTEM_COMPONENTS"
