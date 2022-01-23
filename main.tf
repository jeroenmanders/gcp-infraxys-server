module "project" {
  source             = "./modules/project"
  project_name       = var.project_name
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  parent_folder_id   = var.parent_folder_id
  activate_apis      = var.activate_apis
}

module "network" {
  source       = "./modules/network"
  project_id   = module.project.project_id
  network_name = var.network_name
  allow_ssh    = true
  subnets      = [
    {
      subnet_name           = var.infraxys_subnet_name
      subnet_ip             = var.infraxys_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    },
  ]
}

resource "google_service_account" "infraxys" {
  project      = module.project.project_id
  account_id   = "infraxys"
  display_name = "Infraxys"
  description  = "This account is used for the GCE instance with Infraxys."
}

resource "google_compute_instance" "infraxys" {
  name         = "infraxys"
  depends_on   = [module.network]
  project      = module.project.project_id
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["allow-ssh"]

  boot_disk {
    initialize_params {
      size = 20
      type = "pd-ssd"

      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  #  scratch_disk {
  #    interface = "SCSI"
  #  }

  network_interface {
    network            = module.network.network_id
    subnetwork         = var.infraxys_subnet_name
    subnetwork_project = module.project.project_id
    access_config {

      // Ephemeral public IP
    }
  }

  metadata = {
    name = "infraxys"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email  = google_service_account.infraxys.email
    scopes = ["cloud-platform"]
  }
}
