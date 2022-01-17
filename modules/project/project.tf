
module "gcp-project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 11.3"
  name                        = var.project_name
  random_project_id           = true
  disable_services_on_destroy = false
  folder_id                   = var.parent_folder_id
  org_id                      = var.org_id
  billing_account             = var.billing_account_id
  create_project_sa           = false
  default_service_account     = "disable"
  #labels                      = {}
  lien                        = true # prevent destroy of project
  activate_apis               = var.activate_apis
}