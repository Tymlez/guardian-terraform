resource "aws_eip" "nat" {
  count = 1
  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.aws_vpc_azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false              # <= HA setup
  reuse_nat_ips           = true               # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids     = aws_eip.nat.*.id   # <= IPs specified here as input to the module

  #AWS Tag requirements for EKS 💩
  tags = {
    App = var.app_name
    Terraform = "true"
    Environment = var.stage
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}