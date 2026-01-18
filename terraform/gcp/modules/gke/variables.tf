variable "cluster_name" {
  type = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Cluster location (region or zone)"
  type        = string
}

variable "node_locations" {
  description = "Zones for node placement"
  type        = list(string)
  default     = []
}

variable "network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "disk_size_gb" {
  type = number
}

variable "node_min" {
  type = number
}

variable "node_max" {
  type = number
}

variable "node_count" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

variable "release_channel" {
  type = string
}

variable "logging_components" {
  type = list(string)
}

variable "monitoring_components" {
  type = list(string)
}

variable "service_account" {
  description = "Service account email used by GKE nodes"
  type        = string
}
