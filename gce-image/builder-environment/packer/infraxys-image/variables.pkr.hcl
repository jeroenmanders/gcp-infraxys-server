variable "project_id" {
  description = "ID of the project to use"
  type = string
}

variable "zone" {
  description = "Zone to store the image"
  type = string
}

variable "service_account_email" {
  description = "The service account to be used for launched instance"
  type = string
}

variable "subnetwork" {
  description = "The subnet that the Packer instance should be running in."
  type = string
}