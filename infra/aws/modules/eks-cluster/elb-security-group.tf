#in lieu of a firewall
resource "aws_security_group" "elb_security_group" {
  name        = "${var.stage}-elb_security_group"
  description = "ELB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelisted_ips
  }

  dynamic "ingress" {
    for_each = var.firewall_default == "allow" ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [module.eks]
}



