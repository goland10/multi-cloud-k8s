output "public_subnets" {
  value = var.private_cluster ? null : local.public_subnets
}

output "private_subnets" {
  value = local.private_subnets
}

output "public_eks_endpoint" {
  value = module.eks.cluster_endpoint
}

output "connection_command" {
  description = "Run this command to connect to the cluster public endpoint"
  value       = "eksctl utils write-kubeconfig --cluster ${module.eks.cluster_name} --region ${var.region}"
}

#output "aws_availability_zones" {
#  value = data.aws_availability_zones.available
#}
