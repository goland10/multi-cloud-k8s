module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.6.1"

  vpc_id = module.vpc.vpc_id

  create_security_group = true

  security_group_name        = "vpc-endpoints-sg"
  security_group_description = "Security group for VPC endpoints"

  security_group_rules = {
    ingress_https = {
      description = "Allow HTTPS from VPC"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  endpoints = {
    #Pulls container images stored in ECR (image layers are kept in S3).
    s3_gateway = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "s3-gateway" }
    }
    #There is no need for s3 interface endpoint in this setup
#    s3 = {
#      service             = "s3"
#      subnet_ids          = module.vpc.private_subnets
#      service_type        = "Interface"
#      private_dns_enabled = true
#      dns_options = {
#        private_dns_only_for_inbound_resolver_endpoint = false
#      }
#      tags                = { Name = "s3-interface" }
#    }
#    #Allows the kubelet and nodes to call the ECR control-plane API (DescribeRepositories, GetAuthorizationToken, etc.) to authenticate before pulling images.
#    ecr_api = {
#      service             = "ecr.api"
#      subnet_ids          = module.vpc.private_subnets
#      private_dns_enabled = true
#    }
#    #Gets the image manifest (list of layer digests and metadata) from ecr.dkr
#    ecr_dkr = {
#      service             = "ecr.dkr"
#      subnet_ids          = module.vpc.private_subnets
#      private_dns_enabled = true
#    }
#    #Issues temporary AWS credentials via IRSA (IAM Roles for Service Accounts). 
#    #Pods that assume an IAM role call STS to exchange their OIDC token for short-lived credentials.
#    sts = {
#      service             = "sts"
#      subnet_ids          = module.vpc.private_subnets
#      private_dns_enabled = true
#    }
#    #Used by the EKS control plane and node bootstrap process to describe instances, manage network interfaces (ENIs), 
#    #and allocate IPs under VPC-CNI Prefix Delegation.
#    ec2 = {
#      service             = "ec2"
#      subnet_ids          = module.vpc.private_subnets
#      private_dns_enabled = true
#    }
    #Enables nodes and internal tooling to reach the EKS API without going over the public internet. 
    #Required for the node bootstrap process to register with the control plane.
    eks = {
      service             = "eks"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
    }
    #Routes CloudWatch Logs traffic (control-plane logs, node agent logs, application logs shipped via Fluent Bit or the CloudWatch agent) 
    #to CloudWatch without leaving the VPC.
#    logs = {
#      service             = "logs"
#      subnet_ids          = module.vpc.private_subnets
#      private_dns_enabled = true
#    }
  }

}
