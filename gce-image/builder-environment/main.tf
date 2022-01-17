module "project" {
  source             = "../../modules/project"
  project_name       = var.project_name
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  parent_folder_id   = var.parent_folder_id
  activate_apis      = var.activate_apis
}

module "network" {
  source             = "../../modules/network"
  project_id = module.project.project_id
  network_name = var.network_name
  subnets = [
    {
      subnet_name   = "packer-private-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "europe-west1"
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    },
  ]
}

resource "google_service_account" "packer" {
  account_id   = "packer"
  display_name = "Packer"
  description  = "This account is used to create instances and images using Packer."
  project      = module.project.project_id
}

resource "google_project_iam_binding" "packer_bindings" {
  for_each = toset(var.packer_bindings)

  project = module.project.project_id
  role    = each.value
  members = [
    format("serviceAccount:%s", google_service_account.packer.email),
  ]
}
