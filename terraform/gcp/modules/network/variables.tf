variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "network_name" {
  description = "VPC name"
  type        = string
}

variable "subnets" {
  description = "Subnet configuration per environment"
  type = map(object({
    cidr = string
    pods_cidr = string
    services_cidr = string
  }))
}
