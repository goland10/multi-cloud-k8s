#######################################
# Environment identity
#######################################

variable "env_name" {
  description = "Environment name (e.g. dev-01, staging-01, prod-01)"
  type        = string
}

variable "env_type" {
  description = "Environment type (e.g. dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env_type)
    error_message = "env_type must be one of: dev, staging, prod."
  }
}

#######################################
# Location
#######################################

variable "location" {
  description = "Control plain location (region = master on each zone. zone = single zone master)"
  type        = string
}

variable "node_locations" {
  description = "Additional zones for multi-zonal clusters. Must be null or different from location."
  type        = list(string)
  default     = null

  validation {
    condition = (
      var.node_locations == null ||
      alltrue([
        for zone in var.node_locations :
        zone != var.location
      ])
    )
    error_message = "node_locations must be null or contain zones different from location."
  }
}

#######################################
# Networking
#######################################

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary IP range name for pods"
  type        = string
}

variable "services_range_name" {
  description = "Secondary IP range name for services"
  type        = string
}

#######################################
# Node configuration
#######################################

variable "node_instance_type" {
  description = "GKE node machine type"
  type        = string
}

variable "node_disk_size_gb" {
  description = "Node disk size in GB"
  type        = number
}

variable "node_service_account" {
  description = "Service account email used by GKE nodes"
  type        = string
}

#######################################
# Scaling
#######################################

variable "node_min" {
  description = "Minimum number of nodes"
  type        = number
}

variable "node_max" {
  description = "Maximum number of nodes"
  type        = number
}

variable "node_count" {
  description = "Initial / fixed node count"
  type        = number
}

#######################################
# Cluster behavior
#######################################

variable "deletion_protection" {
  description = "Enable deletion protection on the cluster"
  type        = bool
  default     = false
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)"
  type        = string

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR, or STABLE."
  }
}

#######################################
# Observability
#######################################

variable "logging_components" {
  description = "Enabled logging components"
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS"]
}

variable "monitoring_components" {
  description = "Enabled monitoring components"
  type        = list(string)
  default     = []
}

#######################################
# Labels / tags
#######################################

#variable "labels" {
#  description = "Labels and tags applied to GKE resources"
#  type        = map(string)
#  default     = {}
#}

#######################################
# Labels / cost allocation
#######################################

variable "labels" {
  description = "Common GCP labels applied to GKE cluster and node resources"
  type        = map(string)

  validation {
    condition = alltrue([
      for k, v in var.labels :
      (
        # key validation
        can(regex("^[a-z][a-z0-9_]{0,62}$", k))
        &&
        # value validation (can be empty, but if not empty must match)
        (v == "" || can(regex("^[a-z0-9_-]{0,63}$", v)))
      )
    ])
    error_message = <<EOT
    labels must follow GCP label rules:
    - keys: lowercase letters, numbers, underscores; must start with a letter; max 63 chars
    - values: lowercase letters, numbers, underscores, hyphens; max 63 chars
    - uppercase letters are NOT allowed
    EOT
  }
}