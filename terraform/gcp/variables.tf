#######################################
# Core / identity
#######################################

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  type        = string
  description = "Deployment environment name provided by GitHub Actions (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "region" {
  type        = string
  description = "GCP region where the GKE cluster is deployed"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name provided by GitHub Actions"

  validation {
    condition     = length(var.cluster_name) > 2
    error_message = "cluster_name must be explicitly provided via GitHub Actions"
  }
}

#######################################
# Node pool sizing & compute
#######################################

variable "machine_type" {
  type        = string
  description = "GKE node machine type"
}

variable "disk_size_gb" {
  type        = number
  description = "Boot disk size for GKE nodes (GB)"
}

variable "node_min" {
  type        = number
  description = "Minimum number of nodes for autoscaling"
}

variable "node_max" {
  type        = number
  description = "Maximum number of nodes for autoscaling"
}

variable "node_count" {
  type        = number
  description = "Initial node count (used mainly for dev)"
}

#######################################
# Cluster behavior & safety
#######################################

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection on the GKE cluster"
}

variable "release_channel" {
  type        = string
  description = "GKE release channel (RAPID, REGULAR, STABLE)"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR, or STABLE"
  }
}

#######################################
# Observability
#######################################

variable "logging_components" {
  type        = list(string)
  description = "GKE logging components to enable"
}

variable "monitoring_components" {
  type        = list(string)
  description = "GKE monitoring components to enable"
}
