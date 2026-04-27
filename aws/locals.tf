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
  #public_subnets  = var.private_cluster ? [] : [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 6)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
}

#locals {
#  tags = {
#    created-by = "Golan"
#    Environment  = local.env_name  #.cluster_name
#  }
#}
