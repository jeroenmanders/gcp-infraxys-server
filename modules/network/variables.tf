variable "project_id" {
  description = "ID of the project that the VPC should be created in."
  type        = string
}

variable "network_name" {
  description = "Name of the VPC."
  type        = string
}

variable "subnets" {
  description = "The subnets to create."
  type        = list(map(string))
}

variable "allow_ssh" {
  description = "Create a firewall rule with tag 'allow-ssh' to allow ssh from any IP."
  type        = string
}
