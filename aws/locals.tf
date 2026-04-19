locals {
  # Zero-pad env number (01, 02, etc.)
  env_number_padded = format("%02d", var.env_number)

  # Environment name
  env_name = "${var.env_type}-${local.env_number_padded}"
  cluster_name = local.env_name
}

locals {
  #azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 3, k)]
  private_subnets = var.private_cluster ? [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 3, k + 3)] : null
}

locals {
  tags = {
    created-by = "Golan"
    Environment  = local.env_name  #.cluster_name
  }
}
