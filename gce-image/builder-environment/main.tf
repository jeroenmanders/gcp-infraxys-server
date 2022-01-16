module "infrastructure" {
  source             = "../../modules/infrastructure"
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  project_name       = var.project_name
  parent_folder_id   = var.parent_folder_id
}