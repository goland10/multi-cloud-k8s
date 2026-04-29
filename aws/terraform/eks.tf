module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                                     = local.cluster_name
  kubernetes_version                       = var.kubernetes_version
  endpoint_private_access                  = true
  endpoint_public_access                   = var.private_cluster ? false : true
  enable_cluster_creator_admin_permissions = true

  addons = {
    vpc-cni = {
      before_compute = true # vpc-cni must be deployed before worker nodes
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          #ENABLE_POD_ENI                    = "false"  # Default=false. "true" means "Security Groups for Pods" and it doesn't work with instance type "t3.small"
          ENABLE_PREFIX_DELEGATION          = "true"    # Increase pod density per node to 110. Default=false. AWS assigns a CIDR block (prefix) to each worker node an it manages them locally. 
        }
        nodeAgent = {
          enablePolicyEventLogs = "true"
        }
        enableNetworkPolicy = "true"
      })
    }
    kube-proxy     = {}
#    coredns        = {
#      resolve_conflicts_on_create = "OVERWRITE"
#      resolve_conflicts_on_update = "OVERWRITE"
#    }
#    metrics-server = {
#      resolve_conflicts_on_create = "OVERWRITE"
#      resolve_conflicts_on_update = "OVERWRITE"          
#    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets   #worker nodes subnet placement

  create_security_group      = true # default = true
  create_node_security_group = true # default = true

  timeouts = {
    create = "15m"
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

# Create the delay mechanism
resource "time_sleep" "wait_for_networking" {
  create_duration = "60s"

  # The sleep only starts AFTER the VPC-CNI is fully active
  depends_on = [module.eks] 
}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  
  # This forces Terraform to wait until the sleep is finished
  depends_on = [time_sleep.wait_for_networking]
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name = module.eks.cluster_name
  addon_name   = "metrics-server"
  
  # This forces Terraform to wait until the sleep is finished
  depends_on = [time_sleep.wait_for_networking]
}
