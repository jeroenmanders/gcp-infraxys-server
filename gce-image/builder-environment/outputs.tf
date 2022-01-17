output "project_id" {
  description = "Project ID for the created project."
  value = module.project.project_id
}

output "service_account_id" {
  description = "ID address of the Packer service account."
  value = google_service_account.packer.id
}

output "service_account_email" {
  description = "Email address of the Packer service account."
  value = google_service_account.packer.email
}
