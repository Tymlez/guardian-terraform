resource "google_compute_firewall" "default-allow" {
  count     = var.firewall_default == "ALLOW" ? 1 : 0
  name      = "allow-all"
  network   = var.vpc_name
  direction = "INGRESS"
  priority  = 1

  allow {
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "default-allow-whitelist" {
  count     = var.firewall_default == "DENY" ? 1 : 0
  name      = "allow-whitelist"
  network   = var.vpc_name
  direction = "INGRESS"
  priority  = 2

  allow {
    protocol = "tcp"
  }

  source_ranges = concat(var.whitelisted_ips, var.gcp_local_whitelisted_ips)
}

resource "google_compute_firewall" "default-deny" {
  count     = var.firewall_default == "DENY" ? 1 : 0
  name      = "deny-all-allow-whitelist"
  network   = var.vpc_name
  direction = "INGRESS"
  priority  = 3

  deny {
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]

}