#######################################
# Core / identity
#######################################

variable "environment" {
  type        = string
  description = "Deployment environment label (dev, staging, prod)"
}
#variable "region" {
#  type        = string
#  description = "GCP region where the GKE cluster is deployed"
#}

variable "cluster_name" {
  type        = string
  description = "Final GKE cluster name (already composed by root module)"
}

#######################################
# Networking
#######################################

variable "network" {
  type        = string
  description = "VPC network self-link or name"
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork self-link or name"
}

variable "pods_range_name" {
  type        = string
  description = "Secondary IP range name for pods"
}

variable "services_range_name" {
  type        = string
  description = "Secondary IP range name for services"
}

#######################################
# Identity
#######################################

variable "service_account" {
  type        = string
  description = "Service account email used by GKE nodes"
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
  description = "Initial node count for the primary node pool"
}

variable "location" {
  type = string
}

variable "node_locations" {
  type        = list(string)
  description = "List of zones where nodes should be created"
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
