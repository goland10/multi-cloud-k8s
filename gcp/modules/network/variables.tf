variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string

  validation {
    condition     = length(var.vpc_name) > 0
    error_message = "vpc_name must not be empty."
  }
}

variable "subnet_name" {
  description = "Name of the subnetwork"
  type        = string
}

variable "region" {
  description = "Region where the subnet will be created (e.g. europe-west1)"
  type        = string
}

variable "nodes_cidr" {
  description = "CIDR range for GKE worker nodes"
  type        = string
}

variable "pods_cidr" {
  description = "CIDR range for GKE pods"
  type        = string
}

variable "services_cidr" {
  description = "CIDR range for GKE services"
  type        = string
}

variable "labels" {
  description = "Labels / tags applied to network resources"
  type        = map(string)
  default     = {}
}
