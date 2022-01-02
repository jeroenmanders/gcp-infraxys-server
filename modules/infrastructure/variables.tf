variable "domain" {
  description = "Domain name of the organization we're working under."
  type = string
}

variable "parent_folder_id" {
  description = "ID of the parent folder to use. Leave blank to use the organization."
  type = string
  default = ""
}

variable "project_name" {
  description = "Name of the project."
  type = string
}

