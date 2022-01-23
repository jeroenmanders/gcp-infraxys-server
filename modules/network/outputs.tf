output "network_id" {
  description = "The ID of the VPC."
  value = module.network.network_id
}

output "subnets" {
  description = "Subnet resources."
  value = module.network.subnets
}

output "subnets_ids" {
  description = "Subnet IDs."
  value = module.network.subnets_ids
}