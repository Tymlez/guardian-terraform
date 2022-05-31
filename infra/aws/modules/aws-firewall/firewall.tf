resource "aws_wafv2_ip_set" "allowed_ip_set" {
  name = "${var.stage}-allowed-ip-set"

  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = var.whitelisted_ips
}

resource "aws_wafv2_ip_set" "allowed_local_ip_set" {
  name = "${var.stage}-allowed-local-ip-set"

  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = ["10.0.0.0/8"] #must match subnets
}

module "waf" {
  source      = "registry.terraform.io/umotif-public/waf-webaclv2/aws"
  version     = "3.8.0"
  name_prefix = var.stage
  description = "WAF for EKS"

  allow_default_action   = lower(var.firewall_default) == "allow" ? true : false
  create_alb_association = false

  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.stage}-waf-setup-waf-main-metrics"
    sampled_requests_enabled   = false
  }

  rules = [
    {
      name     = "allow-allowed-ip-set"
      priority = "1"
      action   = "allow"

      ip_set_reference_statement = {
        arn = aws_wafv2_ip_set.allowed_ip_set.arn
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
      }
    },
    {
      name     = "allow-local-ip-set"
      priority = "2"
      action   = "allow"

      ip_set_reference_statement = {
        arn = aws_wafv2_ip_set.allowed_local_ip_set.arn
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
      }
    }
  ]
}