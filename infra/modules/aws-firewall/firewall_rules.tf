data "aws_network_acls" "vpc-acl" {
  vpc_id = var.vpc_id
}

resource "aws_network_acl" "main" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  tags = {
    Terraform = "true"
  }
}
resource "aws_network_acl_rule" "egress-allow" {
  count          = var.firewall_default == "ALLOW" ? 1 : 0
  network_acl_id = data.aws_network_acls.vpc-acl.ids[0]
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  rule_number    = 1
}

resource "aws_network_acl_rule" "default-allow" {
  count          = var.firewall_default == "ALLOW" ? 1 : 0
  network_acl_id = data.aws_network_acls.vpc-acl.ids[0]
  rule_number    = 2
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

#due to AWS silliness we need to allow these always
#shouldn't matter since if all is allowed then these are too
resource "aws_network_acl_rule" "default-allow-whitelist" {
  for_each       = toset(var.whitelisted_ips)
  network_acl_id = data.aws_network_acls.vpc-acl.ids[0]
  rule_number    = index(var.whitelisted_ips, each.value) + 3
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
}

resource "aws_network_acl_rule" "default-deny" {
  count          = var.firewall_default == "DENY" ? 1 : 0
  network_acl_id = data.aws_network_acls.vpc-acl.ids[0]
  rule_number    = 999
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
}
