#######################################
# Environment identity
#######################################
variable "env_type" {
  description = "Environment type (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env_type)
    error_message = "env_type must be one of: dev, staging, prod."
  }
}

variable "env_number" {
  description = "Numeric environment number (e.g. 1 or 01 for dev-01, 2 or 02 for dev-02)"
  type        = number
}

#variable "env_name" {
#  description = "Environment name (e.g. dev-01, staging-01, prod-01)"
#  type        = string
#
#  validation {
#    condition     = length(var.env_name) > 0
#    error_message = "env_name must not be empty."
#  }
#}


variable "runner_service_account" {
  description = "Service account used by GitHub Actions runner"
  type        = string
}

#######################################
# Labels / cost allocation
#######################################
#variable "labels_or_tags" {
#  description = "Labels and tags applied to GKE" 
#  type        = map(string)
#  default     = {}
#}

variable "owner" {
  type        = string
  description = "Owner for this environment"
}

#variable "gcp_labels_aws_tags" {
#  description = "Common GCP labels/AWS tags applied to GKE/EKS cluster and node resources"
#  type        = map(string)
#
#  validation {
#    condition = alltrue([
#      for k, v in var.gcp_labels_aws_tags :
#      (
#        # key validation
#        can(regex("^[a-z][a-z0-9_]{0,62}$", k))
#        &&
#        # value validation (can be empty, but if not empty must match)
#        (v == "" || can(regex("^[a-z0-9_-]{0,63}$", v)))
#      )
#    ])
#    error_message = <<EOT
#    labels_or_tags must follow GCP label rules:
#    - keys: lowercase letters, numbers, underscores; must start with a letter; max 63 chars
#    - values: lowercase letters, numbers, underscores, hyphens; max 63 chars
#    - uppercase letters are NOT allowed
#    EOT
#  }
#}

#######################################
# Provider context
#######################################
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
}

#######################################
# Network
#######################################
#variable "vpc" {
#  description = "VPC / network name"
#  type        = string
#}

#variable "subnet_name" {
#  description = "Name of the subnetwork"
#  type        = string
#}

variable "nodes_cidr" {
  description = "CIDR range for worker nodes"
  type        = string
}

#variable "pods_cidr" {
#  description = "CIDR range for pods"
#  type        = string
#}

#variable "services_cidr" {
#  description = "CIDR range for services"
#  type        = string
#}

#######################################
# IAM (node service account)
#######################################
#variable "node_identity" {
#  description = "Node service account / identity name"
#  type        = string
#}

variable "node_identity_roles" {
  description = "IAM roles attached to the node service account"
  type        = list(string)

  validation {
    condition     = length(var.node_identity_roles) > 0
    error_message = "node_identity_roles must contain at least one role."
  }
}

#######################################
# GKE location
#######################################
variable "location" {
  description = "Region or zone for the GKE cluster"
  type        = string
}

variable "node_locations" {
  description = "Optional additional zones for nodes"
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

    error_message = <<EOT
    node_locations must be null or contain only locations different from 'location'.

    Examples:
    - location = europe-west1-b, node_locations = null ✅
    - location = europe-west1-b, node_locations = ["europe-west1-c"] ✅
    - location = europe-west1-b, node_locations = ["europe-west1-b"] ❌
    EOT
  }
}

#######################################
# GKE node configuration
#######################################
variable "node_instance_type" {
  description = "Node machine / instance type"
  type        = string
}

variable "node_disk_size_gb" {
  description = "Node disk size in GB"
  type        = number
}

variable "node_min" {
  description = "Minimum number of nodes"
  type        = number
}

variable "node_max" {
  description = "Maximum number of nodes"
  type        = number
}

variable "node_count" {
  description = "Initial node count"
  type        = number
  validation {
    condition = (
      var.node_min <= var.node_count &&
      var.node_count <= var.node_max
    )

    error_message = "node_count must be between node_min and node_max."
  }
}

#######################################
# GKE cluster behavior
#######################################
variable "deletion_protection" {
  description = "Enable deletion protection for the GKE cluster"
  type        = bool
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR, or STABLE."
  }
}

variable "logging_components" {
  description = "Enabled GKE logging components"
  type        = list(string)
}

variable "monitoring_components" {
  description = "Enabled GKE monitoring components"
  type        = list(string)
}
