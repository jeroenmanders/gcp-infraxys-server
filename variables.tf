variable "org_id" {
  description = "ID of the organization we're working under."
  type        = string
}

variable "billing_account_id" {
  description = "ID of the billing account to use for the project."
  type        = string
}

variable "project_name" {
  description = "Name of the project for Infraxys."
  type        = string
  default     = "infraxys"
}

variable "parent_folder_id" {
  description = "ID of the parent folder to use. Leave blank to use the organization."
  type        = string
  default     = ""
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = "infraxys"
}

variable "infraxys_subnet_name" {
  description = "Name of the subnet for the Infraxys Server."
  type        = string
  default     = "infraxys-private-01"
}

variable "infraxys_subnet_cidr" {
  description = "CIDR of the subnet for the Infraxys Server."
  type        = string
  default     = "10.10.11.0/27"
}

variable "region" {
  description = "Region to create the resources in."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone for the Infraxys instance."
  type        = string
  default     = "europe-west1-b"
}

variable "machine_type" {
  description = "Machine type of the Infraxys instance."
  type        = string
  default     = "e2-medium"
}

variable "activate_apis" {
  description = "Specify a list of APIs to enable"
  default     = [
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "cloudidentity.googleapis.com"
  ]
}
