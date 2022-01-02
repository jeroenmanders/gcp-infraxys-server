variable "domain" {
  description = "Main domain name of your organization"
  type        = string
}

variable "parent_folder_id" {
  description = "ID of the parent folder to use. Leave blank to use the organization."
  type        = string
  default     = ""
}
