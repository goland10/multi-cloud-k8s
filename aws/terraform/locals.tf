locals {
  # Zero-pad env number (01, 02, etc.)
  env_number_padded = format("%02d", var.env_number)

  # Environment name
  env_name     = "${var.env_type}-${local.env_number_padded}"
  cluster_name = local.env_name
}

data "aws_availability_zones" "available" {
  state = "available"
}

# This resource does nothing but validate your data.
# If the AZs are wrong, Terraform Plan will crash immediately with your error.
resource "terraform_data" "validate_azs" {
  lifecycle {
    precondition {
      # The logic remains the same: Check if all requested AZs exist in AWS
      condition = alltrue([
        for az in distinct(concat(var.azs_public_subnets, var.azs_private_subnets)) :
        contains(data.aws_availability_zones.available.names, az)
      ])

      # The error message now filters for the specific items that failed the check
      error_message = <<EOT
      CRITICAL ERROR: Invalid Availability Zone configuration.
      
      The following AZs are NOT valid in ${var.region}:
      ${join(", ", [for az in distinct(concat(var.azs_public_subnets, var.azs_private_subnets)) : az if !contains(data.aws_availability_zones.available.names, az)])}
      
      Please choose from the available zones in this region:
      ${join(", ", data.aws_availability_zones.available.names)}
      EOT
    }
  }
}

locals {
  # Combine and get unique list of all required AZs
  azs = distinct(concat(var.azs_public_subnets, var.azs_private_subnets))

  public_subnets  = var.private_cluster ? [] : [for i, v in var.azs_public_subnets : cidrsubnet(var.vpc_cidr, 8, i + 6)] #Create public subnets for NAT gateway
  private_subnets = [for i, v in var.azs_private_subnets : cidrsubnet(var.vpc_cidr, 8, i)]                               #Always create private subnets
}

#locals {
#  tags = {
#    created-by = "Golan"
#    Environment  = local.env_name  #.cluster_name
#  }
#}
