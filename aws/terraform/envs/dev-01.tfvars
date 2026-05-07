# -------------------------------------------------------------------
# Environment identity
# -------------------------------------------------------------------
#env_type = "dev"        #Set for manuall test
#env_number = 01         #Set for manuall test
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

# -------------------------------------------------------------------
# IAM (node role)
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Location
# -------------------------------------------------------------------
# AZs for NAT gateway/s. Only for public setup!
azs_public_subnets = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]       

# Deploy NAT gateway in every public subnet (false) or deploy only 1 NAT gateway for all AZS (true)
single_nat_gateway = true         
#private_cluster = false    #Set for manuall test

# Worker node location
azs_private_subnets = ["eu-west-1a","eu-west-1b"] #,"eu-west-1z"]  #At least 2 AZs required.

# -------------------------------------------------------------------
# EKS Worker node configuration
# -------------------------------------------------------------------
instance_types = ["t3.small"]    # t3.medium for dev (minimum for testing), t3.large or m5.large for prod
min_size     = 1
max_size     = 3
desired_size = 1

# -------------------------------------------------------------------
# EKS cluster behavior
# -------------------------------------------------------------------
kubernetes_version = "1.34"

#deletion_protection = false

