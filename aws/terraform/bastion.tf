resource "aws_security_group" "bastion_sg" {
  name        = "${local.cluster_name}-bastion-sg"
  description = "Security group for private bastion host"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.cluster_name}-bastion-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_allow_all_outbound" {
  security_group_id = aws_security_group.bastion_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1" # -1 means all protocols
  description = "Allow all outbound traffic for updates and API communication"
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_to_eks" {
  security_group_id = module.eks.cluster_primary_security_group_id

  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow Bastion host to communicate with EKS API server"
}

resource "aws_iam_role" "bastion_role" {
  name = "${local.cluster_name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_role.name
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${local.cluster_name}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.nano"

  # Place it in your first private subnet where the workers live
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name

  # Security: No public IP address
  associate_public_ip_address = false

  # This script runs once when the instance boots to install kubectl
  user_data = <<-EOT
    #!/bin/bash
    dnf install -y kubectl
  EOT

  tags = {
    Name = "${local.cluster_name}-bastion"
  }
}

resource "aws_iam_policy" "bastion_eks_access" {
  name        = "${local.cluster_name}-bastion-eks-policy"
  description = "Allow bastion to describe the EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "eks:DescribeCluster"
        Effect   = "Allow"
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_eks" {
  policy_arn = aws_iam_policy.bastion_eks_access.arn
  role       = aws_iam_role.bastion_role.name
}

resource "aws_iam_role_policy" "bastion_s3_pull" {
  name = "${local.cluster_name}-bastion-s3-pull"
  role = aws_iam_role.bastion_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::amazon-eks",
          "arn:aws:s3:::amazon-eks/*"
        ]
      }
    ]
  })
}
