module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.6.1"

  vpc_id = module.vpc.vpc_id

  create_security_group = var.private_cluster

  security_group_name        = "vpc-endpoints-sg"
  security_group_description = "Security group for VPC endpoints"

  security_group_rules = var.private_cluster ? {
    ingress_https = {
      description = "Allow HTTPS from VPC"
      cidr_blocks = [var.vpc_cidr]
    }
  } : {}

endpoints = { for k, v in local.endpoints : k => v if var.private_cluster }

}

locals {
  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
    }

    ecr_api = {
      service             = "ecr.api"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
    }

    ecr_dkr = {
      service             = "ecr.dkr"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
    }

    sts = {
      service             = "sts"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
    }

    ec2 = {
      service             = "ec2"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
    }

    eks = {
      service             = "eks"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
    }

    logs = {
      service             = "logs"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
    }
  }  
}
