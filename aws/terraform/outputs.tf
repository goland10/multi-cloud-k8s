#output "public_subnets" {
#  value = local.public_subnets
#}

output "private_subnets" {
  value = local.private_subnets
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}