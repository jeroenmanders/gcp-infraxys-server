
module "seed_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 11.2"
  name                        = var.project_name
  random_project_id           = true
  disable_services_on_destroy = false
  #folder_id                   = google_folder.bootstrap.id
  #org_id                      = local.org_id
  billing_account             = var.billing_account
  create_project_sa           = true
  #labels                      = {}
  lien                        = true # prevent destroy of project

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "securitycenter.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudidentity.googleapis.com"
  ]
}