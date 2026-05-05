resource "aws_security_group" "eic_endpoint_sg" {
  name        = "${local.cluster_name}-eic-endpoint-sg"
  description = "Controls traffic leaving the EIC Endpoint"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.cluster_name}-eic-endpoint-sg"
  }
}

# The specific Egress rule for SSH
resource "aws_vpc_security_group_egress_rule" "eic_to_vpc_ssh" {
  security_group_id = aws_security_group.eic_endpoint_sg.id

  cidr_ipv4   = module.vpc.vpc_cidr_block
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  description = "Allow EIC Endpoint to reach any instance in the VPC via SSH"
}

resource "aws_ec2_instance_connect_endpoint" "this" {
  # Placing it in your first private subnet
  subnet_id = module.vpc.private_subnets[0]

  security_group_ids = [aws_security_group.eic_endpoint_sg.id]

  # Optional: You can preserve the client IP, but for a private bastion, the default (false) is usually fine.
  preserve_client_ip = false

  tags = {
    Name = "${local.cluster_name}-eic-endpoint"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_eic" {
  security_group_id = aws_security_group.bastion_sg.id # The SG attached to your Bastion

  # Link it specifically to the EIC Endpoint's Security Group
  referenced_security_group_id = aws_security_group.eic_endpoint_sg.id

  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  description = "Allow the bastion SSH traffic from the EIC Endpoint"
}