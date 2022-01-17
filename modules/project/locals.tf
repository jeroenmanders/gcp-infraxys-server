locals {
  parent_org_or_folder = var.parent_folder_id == "" ? format("organizations/%s", var.org_id) : format("folders/%s", var.parent_folder_id)

}