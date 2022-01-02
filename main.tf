module "infrastructure" {
  source           = "/modules/infrastructure"
  domain           = var.domain
  parent_folder_id = var.parent_folder_id
}