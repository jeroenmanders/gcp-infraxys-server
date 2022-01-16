variable "org_id" {
  description = "ID of the organization we're working under."
  type = string
}

variable "billing_account_id" {
  description = "ID of the billing account to use for the project."
  type = string
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
