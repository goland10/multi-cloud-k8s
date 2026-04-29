output "public_subnets" {
  value = var.private_cluster ? null : local.public_subnets
}

output "public_eks_endpoint" {
  value = module.eks.cluster_endpoint
}

output "private_subnets" {
  value = local.private_subnets
}

#output "aws_availability_zones" {
#  value = data.aws_availability_zones.available
#}
