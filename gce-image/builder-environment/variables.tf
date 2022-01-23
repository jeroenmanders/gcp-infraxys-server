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

variable "region" {
  description = "Region to create the resources in."
  type        = string
  default     = "europe-west1"
}

variable "activate_apis" {
  description = "Specify a list of APIs to enable"
  default = [
    "sourcerepo.googleapis.com",
    "compute.googleapis.com",
    "servicemanagement.googleapis.com",
    "storage-api.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = "packer-builder"
}

variable "packer_subnet_name" {
  description = "Name of the subnet for Packer instances."
  type        = string
  default     = "packer-private-01"
}

variable "worker_machine_type" {
  description = "Type for the Cloud Build worker pool machines"
  default     = "e2-standard-4"
}

