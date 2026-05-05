output "public_subnets" {
  value = var.private_cluster ? null : local.public_subnets
}

output "private_subnets" {
  value = local.private_subnets
}

output "public_eks_endpoint" {
  value = var.private_cluster ? null : module.eks.cluster_endpoint
}

output "bastion_connection_command" {
  value = var.private_cluster ? (
    <<EOT
    ec2-instance-connect ssh \
    --os-user ec2-user \
    --connection-type eice \
    --instance-id ${aws_instance.bastion.id}
    EOT
  ) : null
}

output "connection_command" {
  description = "Run this command to connect to the cluster public endpoint"
  value       = "eksctl utils write-kubeconfig --cluster ${module.eks.cluster_name} --region ${var.region}"
}

#output "aws_availability_zones" {
#  value = data.aws_availability_zones.available
#}
