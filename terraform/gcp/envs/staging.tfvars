environment  = "staging"
machine_type = "e2-medium"
disk_size_gb = 30

node_min   = 1
node_max   = 3
node_count = 1

deletion_protection = false
release_channel     = "REGULAR"

logging_components = [
  "SYSTEM_COMPONENTS",
  "WORKLOADS"
]

monitoring_components = [
  "SYSTEM_COMPONENTS"
]
