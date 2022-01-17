variable "org_id" {
  description = "ID of the organization we're working under."
  type        = string
}

variable "billing_account_id" {
  description = "ID of the billing account to use for the project."
  type        = string
}

variable "project_name" {
  description = "Name of the project to create Infraxys images with."
  type        = string
  default     = "infraxys-image-builder"
}

variable "parent_folder_id" {
  description = "ID of the parent folder to use. Leave blank to use the organization."
  type        = string
  default     = ""
}


variable "activate_apis" {
  description = "Specify a list of APIs to enable"
  default     = [
    "sourcerepo.googleapis.com",
    "compute.googleapis.com",
    "servicemanagement.googleapis.com",
    "storage-api.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

variable "packer_bindings" {
  description = "List of role bindings to the project for the Packer service account"
  type        = list(string)
  default     = [
    "roles/compute.instanceAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iap.tunnelResourceAccessor",
    "roles/storage.objectViewer"
  ]
}

variable "network_name" {
  description = "Name of the VPC network."
  type = string
  default = "packer-builder"
}