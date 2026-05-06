output "private_subnets" {
  value = local.private_subnets
}

output "public_eks_endpoint" {
  value = var.private_cluster ? null : module.eks.cluster_endpoint
}

output "connection_command" {
  description = "Run this command to connect to the cluster public endpoint"
  value       = "eksctl utils write-kubeconfig --cluster ${module.eks.cluster_name} --region ${var.region}"
}
