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

#variable "cluster_name" {
#  description = "Name of the EKS cluster"
#  type        = string
#  #default     = "dev-01"
#}


#######################################
# Tags / cost allocation
#######################################

variable "owner" {
  type        = string
  description = "Environment owner"
}

################
# Cluster Privacy
################

variable "private_cluster" {
  description = "Whether the GKE cluster should be private"
  type        = bool
  default     = false
}

variable "azs_public_subnets" {
  description = "A list of availability zones names or (ids in the region) to be used by the NAT gateway"
  type        = list(string)
  default     = []

#  validation {
#    condition     = length(var.azs_public_subnets) >= 2
#    error_message = "The EKS control plane requires at least 2 availability zones for high availability."
#  }
}

variable "single_nat_gateway" {
  default = "1 NAT gateway for the whole region or 1 NAT gateway for each AZ."
  type = bool
}

variable "azs_private_subnets" {
  description = "A list of availability zones names or (ids in the region) to be used by the data plane"
  type        = list(string)
  #default     = []
  validation {
    condition     = length(var.azs_private_subnets) >= 2
    error_message = "The EKS requires at least 2 availability zone."
  }
}

variable "kubernetes_version" {
  description = "EKS cluster version."
  type        = string
  #default     = "1.33"
}

variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  #default     = "10.10.0.0/16"
}

variable "region" {
  description = "AWS region"
  type        = string
}
# -------------------------------------------------------------------
# EKS Worker node configuration
# -------------------------------------------------------------------
variable "instance_types" {
  description = "List of instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 6
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

#variable "release_version" {
#  description = "Default EKS AMI release version for node groups"
#  type        = string
#  default     = "1.33.0-20250704"
#}

