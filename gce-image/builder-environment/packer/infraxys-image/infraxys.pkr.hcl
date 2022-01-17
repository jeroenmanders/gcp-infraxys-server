
source "googlecompute" "infraxys" {
  project_id   = var.project_id
  image_name = "infraxys"
  image_description = "GCP image with Infraxys"
#  image_labels = ["Name" = "Infraxys"]
  instance_name = "packer-infraxys-builder"
  machine_type = "n1-standard-1"

  source_image = "ubuntu-minimal-2004-focal-v20220110b"
  ssh_username = "packer"
  subnetwork = var.subnetwork
  zone         = var.zone
  use_internal_ip = true
  omit_external_ip = true
  preemptible = true
  service_account_email = var.service_account_email
  #startup_script_file = "./startup.sh"
  wrap_startup_script = false
  # tags = "https"
}

build {
  sources = ["sources.googlecompute.infraxys"]
}
