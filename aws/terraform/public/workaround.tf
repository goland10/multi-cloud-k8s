#resource "aws_iam_role" "bastion_role" {
#  #count = var.endpoint_access == "private" ? 1 : 0
#  name  = "${local.cluster_name}-bastion-role"
#  assume_role_policy = "{}"
#}

locals {
  bastion_role_arn = null
}