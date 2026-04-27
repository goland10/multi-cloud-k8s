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

  enable_nat_gateway = var.private_cluster ? false : true
  single_nat_gateway = true
  create_igw         = var.private_cluster ? false : true

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
