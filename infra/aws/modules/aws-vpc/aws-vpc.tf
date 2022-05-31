resource "aws_eip" "nat" {
  count = 1
  vpc   = true
}


locals {
  inbound_whitelisted = [for idx, val in var.whitelisted_ips :
    {
      rule_number = 1 + idx
      protocol    = "-1"
      cidr_block = val
      rule_action = "allow"
    }
  ]

  default =  [
    {
      rule_number = 200
      protocol    = "-1"
      cidr_block = "0.0.0.0/0"
      rule_action = var.firewall_default
    }
  ]

  #allow all local
  default_vpc =  [
    {
      rule_number = 100
      protocol    = "-1"
      cidr_block =  "10.0.0.0/8"
      rule_action = "allow"
    },
    {
      rule_number = 101
      protocol    = "-1"
      cidr_block =  "172.16.0.0/12"
      rule_action = "allow"
    },
    {
      rule_number = 102
      protocol    = "-1"
      cidr_block =  "192.168.0.0/16"
      rule_action = "allow"
    }
  ]

  public_outbound =  [
    {
      rule_number = 300
      protocol    = "-1"
      cidr_block = "0.0.0.0/0"
      rule_action = "allow"
    }
  ]
}

module "vpc" {

  source = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.aws_vpc_azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#  public_dedicated_network_acl   = true
#  public_inbound_acl_rules       = concat(local.inbound_whitelisted, local.default_vpc, local.default)
#  public_outbound_acl_rules      = local.public_outbound

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false            # <= HA setup
  reuse_nat_ips          = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids    = aws_eip.nat.*.id # <= IPs specified here as input to the module



  #AWS Tag requirements for EKS 💩
  tags = {
    App                                         = var.app_name
    Terraform                                   = "true"
    Environment                                 = var.stage
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

