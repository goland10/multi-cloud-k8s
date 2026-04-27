terraform {
  backend "s3" {
    bucket = "github-k8s-terraform-state"
    region = "eu-west-1"
    #    key            = "dev/01/terraform.tfstate"
    #t init -backend-config key=$env_type/$env_number/terraform.tfstate
  }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                                     = local.cluster_name
  kubernetes_version                       = var.kubernetes_version
  endpoint_private_access                  = true
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  addons = {
    vpc-cni = {
      before_compute = true # vpc-cni must be deployed before worker nodes
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
        nodeAgent = {
          enablePolicyEventLogs = "true"
        }
        enableNetworkPolicy = "true"
      })
    }
    kube-proxy     = {}
    coredns        = {}
    metrics-server = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_security_group      = true # default = true
  create_node_security_group = true # default = true

  timeouts = {
    create = "10m"
  }

  eks_managed_node_groups = {
    primary_ng = {
      #ami_type       = "AL2023_x86_64_STANDARD"
      create                   = true
      instance_types           = var.instance_types #["t3.small"]  
      use_name_prefix          = false
      iam_role_name            = "${local.cluster_name}-ng-default"
      iam_role_use_name_prefix = false

      min_size     = var.min_size     #2
      max_size     = var.max_size     #6
      desired_size = var.desired_size #2

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        node_group = "primary_ng" #Kubernetes node labels
      }
    }
  }

  #  tags = {
  #    "karpenter.sh/discovery" = local.cluster_name
  #  }
}
locals {
  # Zero-pad env number (01, 02, etc.)
  env_number_padded = format("%02d", var.env_number)

  # Environment name
  env_name     = "${var.env_type}-${local.env_number_padded}"
  cluster_name = local.env_name
}

locals {
  # Determine the maximum count between the two lists
  max_az_count = max(length(var.azs_masters), length(var.azs_workers))

  # Slice the available names from 0 to that maximum count
  azs = slice(data.aws_availability_zones.available.names, 0, local.max_az_count)

  #azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = var.private_cluster ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 6)] : null
}

#locals {
#  tags = {
#    created-by = "Golan"
#    Environment  = local.env_name  #.cluster_name
#  }
#}
output "public_subnets" {
  value = local.public_subnets
}

output "private_subnets" {
  value = local.private_subnets
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }

  required_version = ">= 1.4.2"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      owner       = var.owner
      environment = local.env_name #local.cluster_name
    }
  }
}
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

variable "azs_masters" {
  description = "A list of availability zones names or (ids in the region) to be used by the control plane"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.azs_masters) >= 2
    error_message = "The EKS control plane requires at least 2 availability zones for high availability."
  }
}

variable "azs_workers" {
  description = "A list of availability zones names or (ids in the region) to be used by the data plane"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.azs_workers) >= 1
    error_message = "The EKS data plane requires at least 1 availability zone."
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

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.env_name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  #public_subnet_suffix  = "SubnetPublic"
  #private_subnet_suffix = "SubnetPrivate"

  enable_nat_gateway = true
  single_nat_gateway = true
  create_igw         = true

  enable_dns_support   = true
  enable_dns_hostnames = true


  # Manage so we can name
  manage_default_network_acl    = false
  default_network_acl_tags      = { Name = "${local.cluster_name}-default" }
  manage_default_route_table    = false
  default_route_table_tags      = { Name = "${local.cluster_name}-default" }
  manage_default_security_group = false
  default_security_group_tags   = { Name = "${local.cluster_name}-default" }

  #public_subnet_tags = {
  #  "kubernetes.io/role/elb" = "1"
  #}
  private_subnet_tags = {
    #"karpenter.sh/discovery"          = local.cluster_name
    "kubernetes.io/role/internal-elb" = "1"
  }

  #tags = local.tags
}
# -------------------------------------------------------------------
# Environment identity
# -------------------------------------------------------------------
env_type = "dev"
env_number = 01
#env_name = "dev-01"

region = "eu-west-1"

# -------------------------------------------------------------------
# Labels / cost allocation
# -------------------------------------------------------------------
owner = "yaniv"

# -------------------------------------------------------------------
# Network
# -------------------------------------------------------------------
#vpc           = "dev-01"
vpc_cidr    = "10.10.0.0/16"    #This is the base cidr
#pods_cidr     = "10.20.0.0/16"   #base cidr second octet + 10
#services_cidr = "10.30.0.0/20"   #base cidr second octet + 20

# -------------------------------------------------------------------
# IAM (node service account)
# -------------------------------------------------------------------
#node_identity = "dev-01-node-identity"

#node_identity_roles = [
#  "roles/logging.logWriter",
#  "roles/monitoring.metricWriter",
#  "roles/monitoring.viewer",
#]

# -------------------------------------------------------------------
# Location
# -------------------------------------------------------------------
# Control plain node location
azs_masters = ["eu-west-1a", "eu-west-1b"]              #At least 2 AZs
private_cluster = true

# Worker node location
azs_workers = ["eu-west-1a","eu-west-1b","eu-west-1c"]  # 1 AZ for single-node cluster, 2 AZs for dual-zone cluster, 3 AZs for multi-zone cluster
# -------------------------------------------------------------------
# EKS Worker node configuration
# -------------------------------------------------------------------
instance_types           = ["t3.small"]
min_size     = 2
max_size     = 6
desired_size = 2
#release_version = "1.33.0-20250704"
#node_instance_type = "e2-standard-4"  # e2-medium | e2-standard-4 | n2-standard-4
#node_disk_size_gb  = 30           # 20 | 30 | 50
#

# -------------------------------------------------------------------
# GKE cluster behavior
# -------------------------------------------------------------------
kubernetes_version = "1.35"

#deletion_protection = false
#release_channel     = "RAPID"   # RAPID | REGULAR | STABLE and more
#
#logging_components    = ["SYSTEM_COMPONENTS"]   # "SYSTEM_COMPONENTS"
#monitoring_components = ["SYSTEM_COMPONENTS"]   # "SYSTEM_COMPONENTS"
