resource "aws_eip" "nat" {
  count = 1
  vpc   = true
}


locals {
  inbound_whitelisted = [for idx, val in var.whitelisted_ips :
    {
      rule_number = 1 + idx
      protocol    = "-1"
      cidr_block  = val
      rule_action = "allow"
    }
  ]

  default = [
    {
      rule_number = 200
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      rule_action = var.firewall_default
    }
  ]

  #allow all local
  default_vpc = [
    {
      rule_number = 100
      protocol    = "-1"
      cidr_block  = "10.0.0.0/8"
      rule_action = "allow"
    },
    {
      rule_number = 101
      protocol    = "-1"
      cidr_block  = "172.16.0.0/12"
      rule_action = "allow"
    },
    {
      rule_number = 102
      protocol    = "-1"
      cidr_block  = "192.168.0.0/16"
      rule_action = "allow"
    }
  ]

  public_outbound = [
    {
      rule_number = 300
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      rule_action = "allow"
    }
  ]
  #I have no idea why this is required in Terraform
  #referencing them directly in the module fails
  az1_name = try(var.aws_vpc_config.az1.az_name)
  az2_name = try(var.aws_vpc_config.az2.az_name)
  az3_name = try(var.aws_vpc_config.az3.az_name)

  az1_private = try(var.aws_vpc_config.az1.private_subnet)
  az2_private = try(var.aws_vpc_config.az2.private_subnet)
  az3_private = try(var.aws_vpc_config.az3.private_subnet)

  az1_public = try(var.aws_vpc_config.az1.public_subnet)
  az2_public = try(var.aws_vpc_config.az2.public_subnet)
  az3_public = try(var.aws_vpc_config.az3.public_subnet)
}

module "vpc" {

  source = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  name   = var.vpc_name
  cidr   = var.vpc_cidr

  azs             = [local.az1_name, local.az2_name, local.az3_name]
  private_subnets = [local.az1_private, local.az2_private, local.az3_private]
  public_subnets  = [local.az1_public, local.az2_public, local.az3_public]

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

