source "googlecompute" "infraxys" {
  project_id        = var.project_id
  image_name        = "infraxys"
  image_description = "GCP image with Infraxys"
  image_labels      = {
    "name" : "infraxys",
    "blalba" : "yes"
  }

  instance_name         = "packer-infraxys-builder"
  machine_type          = "n2-standard-2"
  ssh_timeout           = "1h"
  # source_image          = "ubuntu-pro-2004-focal-v20220118" # Error getting source image for instance creation: Could not find image, ubuntu-pro-2004-focal-v20220118, in projects, [infraxys-image-builder-80ed centos-cloud cos-cloud coreos-cloud debian-cloud rhel-cloud rhel-sap-cloud suse-cloud suse-sap-cloud suse-byos-cloud ubuntu-os-cloud windows-cloud windows
  source_image          = "ubuntu-2004-focal-v20220118"
  # source_image          = "ubuntu-minimal-2004-focal-v20220110b"
  ssh_username          = "packer"
  subnetwork            = var.subnet
  zone                  = var.zone
  use_internal_ip       = true
  omit_external_ip      = true
  preemptible           = true
  service_account_email = var.service_account_email
  startup_script_file   = "./install-infraxys.sh"
  wrap_startup_script   = false
  tags                  = [
    "allow-ssh",
  ]
}

build {
  sources = ["sources.googlecompute.infraxys"]
}
