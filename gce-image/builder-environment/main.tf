module "project" {
  source             = "../../modules/project"
  project_name       = var.project_name
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  parent_folder_id   = var.parent_folder_id
  activate_apis      = var.activate_apis
}

resource "google_project_service" "servicenetworking" {
  service            = "servicenetworking.googleapis.com"
  project            = module.project.project_id
  disable_on_destroy = false
}

module "network" {
  source       = "../../modules/network"
  project_id   = module.project.project_id
  network_name = var.network_name
  allow_ssh    = true
  subnets      = [
    {
      subnet_name           = var.packer_subnet_name
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    },
  ]
}

resource "google_compute_global_address" "worker_range" {
  name          = "worker-pool-range"
  project       = module.project.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.network.network_id
}

resource "google_service_networking_connection" "worker_pool_conn" {
  network                 = module.network.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.worker_range.name]
  depends_on              = [google_project_service.servicenetworking]
}

resource "google_cloudbuild_worker_pool" "pool" {
  name       = "my-pool"
  location   = var.region
  project    = module.project.project_id
  worker_config {
    disk_size_gb   = 100
    machine_type   = var.worker_machine_type
    no_external_ip = false
  }
  network_config {
    peered_network = module.network.network_id
  }
  depends_on = [google_service_networking_connection.worker_pool_conn]
}

resource "google_service_account" "packer" {
  project      = module.project.project_id
  account_id   = "packer"
  display_name = "Packer"
  description  = "This account is used to create instances and images using Packer."
}

resource "google_service_account" "cloudbuild_service_account" {
  project      = module.project.project_id
  account_id   = "packer-cloud-builder"
  display_name = "Packer Cloud Builder"
  description  = "Used to run cloud builds."
}

resource "google_project_service_identity" "cloudbuild" {
  provider = google-beta

  project = module.project.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_iam_member" "roles" {
  for_each = {
  for role_member in local.role_members : format("%s :: %s", role_member.role, role_member.member) => role_member
  }
  project  = module.project.project_id
  role     = each.value.role
  member   = each.value.member == "cloudbuild" ? format("serviceAccount:%s", google_project_service_identity.cloudbuild.email) : format("%s@%s.iam.gserviceaccount.com", each.value.member, module.project.project_id)
}
