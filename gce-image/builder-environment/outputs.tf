output "project_id" {
  description = "Project ID for the created project."
  value       = module.project.project_id
}

output "region" {
  description = "Region of the Packer subnet and other resources."
  value       = var.region
}

output "service_account_id" {
  description = "ID of the Packer service account."
  value       = google_service_account.packer.id
}

output "service_account_email" {
  description = "Email address of the Packer service account."
  value       = google_service_account.packer.email
}

output "packer_subnet_id" {
  description = "Subnet ID for Packer instances"
  value       = module.network.subnets_ids[0]
}

output "cloudbuild_pool" {
  description = "Cloud Build pool to use for image creation."
  value       = google_cloudbuild_worker_pool.pool.id
}
