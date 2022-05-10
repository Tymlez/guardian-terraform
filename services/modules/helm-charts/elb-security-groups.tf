data "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_security_group" "fully_open" {
  name_prefix = "fully_open"
  vpc_id      = data.aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

