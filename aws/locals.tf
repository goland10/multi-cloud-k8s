locals {
  tags = {
    created-by = "eks-workshop-v2"
    env        = var.cluster_name
  }
}

locals {
  # Zero-pad env number (01, 02, etc.)
  env_number_padded = format("%02d", var.env_number)

  # Environment name
  env_name = "${var.env_type}-${local.env_number_padded}"
}

locals {
  #azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 3, k)]
  private_subnets = var.private_cluster ? [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 3, k + 3)] : null
}
