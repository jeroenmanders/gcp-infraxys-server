module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0.1"
  project_id   = var.project_id
  network_name = var.network_name

  subnets = var.subnets
}

resource "google_compute_firewall" "ssh-rule" {
  count         = var.allow_ssh ? 1 : 0
  depends_on    = [module.network]
  name          = "allow-ssh"
  project       = var.project_id
  network       = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
}