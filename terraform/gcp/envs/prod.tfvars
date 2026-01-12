environment  = "prod"
machine_type = "e2-standard-2"
disk_size_gb = 50

node_min   = 2
node_max   = 6
node_count = 2

deletion_protection = true
release_channel     = "STABLE"

logging_components = [
  "SYSTEM_COMPONENTS",
  "WORKLOADS"
]

monitoring_components = [
  "SYSTEM_COMPONENTS"
]
