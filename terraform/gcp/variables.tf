#######################################
# Global / Project
#######################################

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
}

#variable "environment" {
#  description = "Deployment environment"
#  type        = string
#
#  #validation {
#  #  condition     = contains(["dev", "staging", "prod"], var.environment)
#  #  error_message = "environment must be one of: dev, staging, prod"
#  #}
#}

#######################################
# IAM
#######################################

variable "nodes_sa_id" {
  description = "Service account ID used by GKE nodes"
  type        = string
}

#######################################
# Network
#######################################

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnets" {
  description = "Subnet configuration per environment"
  type = map(object({
    cidr          = string
    pods_cidr     = string
    services_cidr = string
  }))
}

#######################################
# GKE Clusters
#######################################
variable "clusters" {
  description = "GKE cluster definitions"

  type = map(object({
    environment      = string
    region_or_zone   = string

    # Optional: allow per-cluster zone control
    node_locations = optional(list(string))

    machine_type = string
    disk_size_gb = number

    node_min   = number
    node_max   = number
    node_count = number

    deletion_protection = bool
    release_channel     = string

    logging_components     = list(string)
    monitoring_components = list(string)
  }))

  validation {
    condition = alltrue([
      for _, cluster in var.clusters :
      cluster.node_locations == null
      || alltrue([
        for zone in cluster.node_locations :
        zone != cluster.region_or_zone
      ])
    ])

    error_message = <<EOT
    If node_locations is provided, none of its entries may be equal to
    region_or_zone.

    Examples:
    - region_or_zone = europe-west1 → node_locations = ["europe-west1-b"] ✅
    - region_or_zone = europe-west1-b → node_locations = ["europe-west1-c"] ✅
    - region_or_zone = europe-west1-b → node_locations = ["europe-west1-b"] ❌
    EOT
  }

}
